import mongoose from 'mongoose';
import { ApiError } from '../utils/apiError.js';
import { CatalogSettings } from '../models/index.js';

export async function activeCatalogSetting(){
  if(mongoose.connection.readyState!==1)throw new ApiError(503,'Cơ sở dữ liệu chưa sẵn sàng.');
  return CatalogSettings.findById('active').lean();
}
export function publicTrackFilter(setting,{fullAudioOnly=true}={}){
  const local={catalog_dataset:{$in:[null,'']}};
  return {status:'active',deleted_at:null,...(setting?.dataset?{$or:[{catalog_dataset:setting.dataset},local]}:local),
    ...(setting?.audio_only&&fullAudioOnly?{audio_url:{$type:'string',$ne:''}}:{})};
}
export async function publicTracks(options){return publicTrackFilter(await activeCatalogSetting(),options);}
