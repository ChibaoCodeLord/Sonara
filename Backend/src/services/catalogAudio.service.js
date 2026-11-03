import {MediaImports} from './mediaImport.service.js';
import {Track} from '../models/track.model.js';
import {fileURLToPath} from 'node:url';
import {verifyMp3} from './youtubeBulk.service.js';
import {activeCatalogSetting,publicTrackFilter} from './catalogPolicy.service.js';
export class CatalogAudio {
  constructor({service=new MediaImports({root:fileURLToPath(new URL('../../temp/catalog-audio-library/',import.meta.url))}),tracks=Track,settings=activeCatalogSetting,verify=verifyMp3}={}){
    this.service=service;this.tracks=tracks;this.settings=settings;this.verify=verify;this.initialized=null;this.requests=new Map();this.publications=new Map();
  }
  async init(){if(!this.initialized)this.initialized=this.service.init().catch(e=>{this.initialized=null;throw e;});await this.initialized;}
  async publish(job){
    if(job.status!=='ready')return;
    const verification=await this.verify(this.service.audioPath(job.id));
    const setting=await this.settings();
    const filter={...publicTrackFilter(setting,{fullAudioOnly:false}),'youtube.url':job.url,'audio_cache.storage':{$ne:'youtube-bulk'},
      $and:[{$or:[{audio_url:{$in:['',null]}},{'audio_cache.storage':'catalog-audio','audio_cache.source_url':job.url},{'audio_cache.job_id':job.id,'audio_cache.source_url':job.url}]}]};
    await this.tracks.updateMany(filter,{$set:{audio_url:`/api/v1/catalog/audio/jobs/${job.id}/stream`,audio_cache:{storage:'catalog-audio',job_id:job.id,source_url:job.url,...verification,ready_at:new Date()}}});
    job.catalog_state='published';await this.service.persist?.(job);
  }
  schedule(job){
    if(job.catalog_state==='published')return Promise.resolve();
    if(this.publications.has(job.id))return this.publications.get(job.id);
    job.catalog_state='publishing';
    const wait=this.service.tasks?.get(job.id)||Promise.resolve();
    const task=wait.then(()=>this.publish(job)).catch(()=>{job.catalog_state='failed';job.catalog_error='Chưa lưu được audio vào catalog. Hãy thử lại.';}).finally(()=>this.publications.delete(job.id));
    this.publications.set(job.id,task);return task;
  }
  async prepare(videoId){
    if(!/^[\w-]{11}$/.test(videoId||''))throw Object.assign(new Error('YouTube ID không hợp lệ.'),{status:400});
    await this.init();const url=`https://www.youtube.com/watch?v=${videoId}`;
    const existing=[...this.service.jobs.values()].find(j=>j.url===url&&['ready','metadata','downloading','converting'].includes(j.status));
    if(existing){this.schedule(existing);return this.result(existing);}
    if(this.requests.has(videoId))return this.requests.get(videoId);
    const request=this.service.create(url).then(job=>{this.schedule(job);return this.result(job);}).finally(()=>this.requests.delete(videoId));this.requests.set(videoId,request);return request;
  }
  result(job){
    if(job.catalog_state==='failed')return {...job,status:'failed',error:job.catalog_error,track:undefined};
    if(job.status!=='ready'||job.catalog_state==='publishing')return {...job,status:job.status==='ready'?'converting':job.status,track:undefined};
    return {...job,track:{...job.track,audioUrl:`/api/v1/catalog/audio/jobs/${job.id}/stream`}};
  }
  async get(id){await this.init();const job=this.service.get(id);return job?this.result(job):null;}
}
export const catalogAudio=new CatalogAudio();
