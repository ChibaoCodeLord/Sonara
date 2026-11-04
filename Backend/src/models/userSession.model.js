import mongoose from 'mongoose';
const schema=new mongoose.Schema({
  user_id:{type:mongoose.Schema.Types.ObjectId,ref:'User',required:true,index:true},
  refresh_token_hash:{type:String,required:true,unique:true,select:false},
  family_id:{type:String,required:true,index:true},
  expires_at:{type:Date,required:true},
  revoked_at:{type:Date,default:null},
  device_id:{type:String,default:''},device_name:{type:String,default:''},
  created_at:{type:Date,default:Date.now}
},{versionKey:false});
schema.index({expires_at:1},{expireAfterSeconds:0});
export const UserSession=mongoose.model('UserSession',schema,'user_sessions');
