import {Playlist,PlaylistTrack,User,Track} from '../models/index.js';
import {ApiError} from '../utils/apiError.js';
import {text,objectId,boolean,idList,pagination,integer} from '../utils/validation.js';
import {transaction} from '../utils/transaction.js';
import {publicTracks} from './catalogPolicy.service.js';
import {enrichTracks,getPublicTrack} from './track.service.js';
import {pageInfo} from './catalogBrowse.service.js';
import {inspectMedia} from './adminUpload.service.js';

export function canReadPlaylist(p,user){return p.is_public||Boolean(user&&(String(p.owner_id)===String(user._id)||p.collaborative&&(p.collaborator_ids||[]).some(id=>String(id)===String(user._id))));}
function assertEdit(p,user,tracks=false){if(String(p.owner_id)===String(user._id))return;if(tracks&&p.collaborative&&(p.collaborator_ids||[]).some(id=>String(id)===String(user._id)))return;throw new ApiError(403,'Bạn không có quyền sửa playlist này.');}
const summary=p=>({...p,id:String(p._id),title:p.name,coverUrl:p.image_url||''});
async function updateFields(body){
  const fields={};if(body.title!==undefined||body.name!==undefined)fields.name=text(body.title??body.name,'title',{max:200});
  if(body.description!==undefined)fields.description=text(body.description,'description',{min:0,max:2000});
  for(const k of ['is_public','collaborative'])if(body[k]!==undefined)fields[k]=boolean(body[k],k);
  if(body.collaborator_ids!==undefined){fields.collaborator_ids=idList(body.collaborator_ids,'collaborator_ids',20);if(await User.countDocuments({_id:{$in:fields.collaborator_ids},status:{$nin:['banned','suspended']}})!==fields.collaborator_ids.length)throw new ApiError(400,'Collaborator không tồn tại hoặc không hoạt động.');}
  return fields;
}
export async function createPlaylist(user,body){
  const fields=await updateFields(body);if(!fields.name)throw new ApiError(400,'Tên playlist là bắt buộc.');
  return transaction(async session=>{
    await User.updateOne({_id:user._id},{$inc:{playlist_revision:1}},{session});
    if(await Playlist.countDocuments({owner_id:user._id}).session(session)>=50)throw new ApiError(409,'Tối đa 50 playlist cá nhân.');
    const [row]=await Playlist.create([{...fields,owner_id:user._id}],{session});return summary(row.toObject());
  });
}
export async function playlistDetail(id,user,query={}){
  const row=await Playlist.findById(objectId(id,'Playlist ID')).lean();if(!row||!canReadPlaylist(row,user))throw new ApiError(404,'Không tìm thấy playlist.');
  const {page,limit}=pagination(query,50),filter=await publicTracks();
  const [data]=await PlaylistTrack.aggregate([{$match:{playlist_id:row._id}},{$sort:{position:1,_id:1}},{$lookup:{from:'tracks',localField:'track_id',foreignField:'_id',pipeline:[{$match:filter}],as:'track'}},{$unwind:'$track'},{$facet:{total:[{$count:'count'}],rows:[{$skip:(page-1)*limit},{$limit:limit}]}}]);
  return {...summary(row),tracks:await enrichTracks((data?.rows||[]).map(r=>r.track)),pagination:pageInfo(data?.total[0]?.count||0,page,limit)};
}
export async function listPlaylists(user,query={}){
  const {page,limit}=pagination(query),filter={$or:[{owner_id:user._id},{collaborative:true,collaborator_ids:user._id}]};
  const [rows,total]=await Promise.all([Playlist.find(filter).sort({updated_at:-1,_id:-1}).skip((page-1)*limit).limit(limit).lean(),Playlist.countDocuments(filter)]);
  const counts=await PlaylistTrack.aggregate([{$match:{playlist_id:{$in:rows.map(r=>r._id)}}},{$lookup:{from:'tracks',localField:'track_id',foreignField:'_id',pipeline:[{$match:await publicTracks()}],as:'track'}},{$unwind:'$track'},{$group:{_id:'$playlist_id',count:{$sum:1}}}]);const byId=new Map(counts.map(r=>[String(r._id),r.count]));
  return {playlists:rows.map(p=>({...summary(p),tracksCount:byId.get(String(p._id))||0})),pagination:pageInfo(total,page,limit)};
}
export async function mutatePlaylist(user,id,action,body={},options={}){
  const _id=objectId(id,'Playlist ID');const fields=action==='update'?await updateFields(body):null;
  if(options.cover&&fields){await inspectMedia(options.cover,{cover:true});fields.image_url='/uploads/'+options.cover.filename;}
  const newTrack=action==='add'?await getPublicTrack(body.song_id??body.track_id):null;
  const removeId=action==='remove'?objectId(body.song_id,'Song ID'):null;
  let order;
  if(action==='reorder'){
    if(!Array.isArray(body.track_orders)||body.track_orders.length>1000)throw new ApiError(400,'track_orders không hợp lệ.');
    order=body.track_orders.map(r=>{if(!r||typeof r!=='object')throw new ApiError(400,'track_orders không hợp lệ.');return {id:objectId(r.song_id,'song_id'),position:integer(r.track_order,'track_order',{min:0,max:999})};});
    if(new Set(order.map(r=>String(r.id))).size!==order.length||new Set(order.map(r=>r.position)).size!==order.length||order.some(r=>r.position>=order.length))throw new ApiError(400,'Thứ tự phải duy nhất, liên tục từ 0 và đủ bài.');
  }
  return transaction(async session=>{
    const row=await Playlist.findById(_id).session(session);if(!row)throw new ApiError(404,'Không tìm thấy playlist.');assertEdit(row,user,['add','remove','reorder'].includes(action));
    if(body.expected_revision!==undefined&&integer(body.expected_revision,'expected_revision',{min:0,max:Number.MAX_SAFE_INTEGER})!==(row.revision||0))throw new ApiError(409,'Playlist đã thay đổi. Hãy tải lại.');
    // Every mutation touches the parent, serializing track membership and order.
    await Playlist.updateOne({_id},{$inc:{revision:1},$set:{updated_at:new Date()}},{session});
    if(action==='delete'){
      if(row.is_ai_generated)throw new ApiError(403,'Không thể xóa playlist hệ thống AI.');
      await User.updateOne({_id:user._id},{$inc:{playlist_revision:1}},{session});await PlaylistTrack.deleteMany({playlist_id:_id},{session});await Playlist.deleteOne({_id},{session});return null;
    }
    if(action==='update'){if(!Object.keys(fields).length)throw new ApiError(400,'Không có trường cập nhật hợp lệ.');await Playlist.updateOne({_id},{$set:fields},{session,runValidators:true});}
    else{
      const links=await PlaylistTrack.find({playlist_id:_id}).sort({position:1,_id:1}).session(session);
      if(action==='add'){
        if(links.some(l=>String(l.track_id)===String(newTrack._id)))throw new ApiError(409,'Bài hát đã có trong playlist.');
        if(links.length>=1000)throw new ApiError(409,'Playlist tối đa 1.000 bài.');
        await PlaylistTrack.create([{playlist_id:_id,track_id:newTrack._id,added_by:user._id,position:links.length}],{session});
      }else if(action==='remove'){
        if(!links.some(l=>String(l.track_id)===String(removeId)))throw new ApiError(404,'Bài hát không có trong playlist.');
        await PlaylistTrack.deleteOne({playlist_id:_id,track_id:removeId},{session});
        const rest=links.filter(l=>String(l.track_id)!==String(removeId));if(rest.length)await PlaylistTrack.bulkWrite(rest.map((l,i)=>({updateOne:{filter:{_id:l._id},update:{$set:{position:i}}}})),{session});
      }else if(action==='reorder'){
        if(links.length!==order.length||links.some(l=>!order.some(r=>String(r.id)===String(l.track_id))))throw new ApiError(400,'track_orders phải chứa chính xác tất cả bài trong playlist.');
        if(order.length)await PlaylistTrack.bulkWrite(order.map(r=>({updateOne:{filter:{playlist_id:_id,track_id:r.id},update:{$set:{position:r.position}}}})),{session});
      }
    }
    return summary((await Playlist.findById(_id).session(session).lean()));
  });
}
