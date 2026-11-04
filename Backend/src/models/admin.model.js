import mongoose from 'mongoose';
const options={versionKey:false,timestamps:{createdAt:'created_at',updatedAt:'updated_at'}};
const genreSchema=new mongoose.Schema({name:{type:String,required:true,maxlength:80},slug:{type:String,required:true,unique:true,maxlength:120},active:{type:Boolean,default:true},revision:{type:Number,default:0}},options);
export const Genre=mongoose.model('Genre',genreSchema,'genres');
const auditSchema=new mongoose.Schema({actor_id:{type:mongoose.Schema.Types.ObjectId,ref:'User',required:true},dataset:String,status:{type:String,enum:['running','completed','failed'],required:true},total:{type:Number,default:0},checked:{type:Number,default:0},counts:{type:mongoose.Schema.Types.Mixed,default:{}},issues:{type:[mongoose.Schema.Types.Mixed],default:[]},truncated:{type:Boolean,default:false},error:String,finished_at:Date},options);
auditSchema.index({created_at:-1});
export const AudioAudit=mongoose.model('AudioAudit',auditSchema,'audio_audits');
