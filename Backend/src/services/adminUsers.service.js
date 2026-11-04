import {User,UserSession,Playlist,LikedTrack,AdminAuditLog} from '../models/index.js';
import {ApiError} from '../utils/apiError.js';
import {objectId,text,pagination,choice,integer,escapeRegex} from '../utils/validation.js';
import {transaction} from '../utils/transaction.js';
import {pageInfo} from './catalogBrowse.service.js';
const fields='email display_name avatar_url country role status created_at admin_revision';
const dto=r=>({id:String(r._id),email:r.email,name:r.display_name,avatar_url:r.avatar_url||'',country:r.country,role:r.role||'user',status:r.status||'active',created_at:r.created_at,revision:r.admin_revision||0});
export async function users(query){const {page,limit}=pagination(query),filter={};if(query.q){const regex={$regex:escapeRegex(text(query.q,'q',{max:200})),$options:'i'};filter.$or=[{email:regex},{display_name:regex}];}if(query.status)filter.status=choice(query.status,'status',['active','banned','suspended']);const [rows,total]=await Promise.all([User.find(filter).select(fields+' +admin_revision').sort({created_at:-1,_id:1}).skip((page-1)*limit).limit(limit).lean(),User.countDocuments(filter)]);return {users:rows.map(dto),pagination:pageInfo(total,page,limit)};}
export async function userDetail(id){const _id=objectId(id),user=await User.findById(_id).select(fields+' +admin_revision').lean();if(!user)throw new ApiError(404,'Không tìm thấy người dùng.');const [sessions,playlists,likes]=await Promise.all([UserSession.find({user_id:_id}).select('device_name created_at expires_at revoked_at').sort({created_at:-1}).limit(30).lean(),Playlist.countDocuments({owner_id:_id}),LikedTrack.countDocuments({user_id:_id})]);return {...dto(user),sessions,playlists_count:playlists,likes_count:likes};}
export async function mutateUser(actor,id,body,revokeOnly=false){
  const _id=objectId(id);if(body.role!==undefined)throw new ApiError(400,'Cấp quyền admin cần quy trình quản trị tài khoản riêng.');const reason=text(body.reason,'reason',{min:3,max:1000}),status=revokeOnly?null:choice(body.status,'status',['active','banned','suspended']);
  return transaction(async session=>{
    const liveActor=await User.findById(actor._id).session(session);if(!liveActor||liveActor.role!=='admin'||liveActor.status!=='active')throw new ApiError(403,'Quyền quản trị đã bị thu hồi.');await User.updateOne({_id:actor._id},{$inc:{admin_revision:1}},{session});
    const target=await User.findById(_id).select('+token_version +admin_revision').session(session);if(!target)throw new ApiError(404,'Không tìm thấy người dùng.');
    if(body.expected_revision!==undefined&&integer(body.expected_revision,'expected_revision',{min:0,max:Number.MAX_SAFE_INTEGER})!==(target.admin_revision||0)-(String(target._id)===String(actor._id)?1:0))throw new ApiError(409,'Người dùng đã thay đổi. Hãy tải lại.');
    if(!revokeOnly&&status!=='active'&&String(target._id)===String(actor._id))throw new ApiError(409,'Không thể tự khóa tài khoản đang quản trị.');
    if(!revokeOnly&&target.role==='admin'&&status!=='active'&&await User.countDocuments({role:'admin',status:'active'}).session(session)<=1)throw new ApiError(409,'Phải giữ ít nhất một quản trị viên hoạt động.');
    const before={status:target.status||'active',role:target.role||'user'};
    if(!revokeOnly)target.status=status;target.token_version=(target.token_version||0)+1;target.admin_revision=(target.admin_revision||0)+1;await target.save({session});
    const revoked=await UserSession.updateMany({user_id:_id,revoked_at:null},{$set:{revoked_at:new Date()}},{session});await AdminAuditLog.create([{actor_id:actor._id,action:revokeOnly?'USER_SESSIONS_REVOKED':'USER_STATUS_UPDATED',target_id:_id,target_type:'user',before,after:{status:target.status,reason,revoked_sessions:revoked.modifiedCount}}],{session});return {id:String(_id),status:target.status,revision:target.admin_revision,revoked_sessions:revoked.modifiedCount};
  });
}
