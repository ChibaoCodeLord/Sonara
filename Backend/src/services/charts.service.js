import {ListeningHistory,Track} from '../models/index.js';
import {choice} from '../utils/validation.js';
import {publicTracks} from './catalogPolicy.service.js';
import {enrichTracks} from './track.service.js';
export async function chart(region,query={}){
  const timeframe=choice(query.timeframe||'week','timeframe',['week','month']),since=new Date(Date.now()-(timeframe==='week'?7:30)*86400000);
  const filter={...await publicTracks(),...(region==='VN'?{'catalog_metadata.region':'VN'}:region==='INTL'?{'catalog_metadata.region':'INTL'}:{})};
  const counts=await ListeningHistory.aggregate([{$match:{completed:true,completed_at:{$gte:since}}},{$lookup:{from:'tracks',localField:'track_id',foreignField:'_id',pipeline:[{$match:filter}],as:'track'}},{$unwind:'$track'},{$group:{_id:'$track_id',completed_listens:{$sum:1},track:{$first:'$track'}}},{$sort:{completed_listens:-1,_id:1}},{$limit:50}]);
  const tracks=await enrichTracks(counts.map(r=>r.track));return {timeframe,region:region||'ALL',since,basis:'completed_listens',tracks:counts.map((r,i)=>({...tracks[i],rank:i+1,completed_listens:r.completed_listens}))};
}
export async function spotlight(){const tracks=await Track.find({...await publicTracks(),'catalog_metadata.is_spotlight':true}).sort({imported_at:-1,_id:1}).limit(10).lean();return {basis:'editorial',tracks:await enrichTracks(tracks)};}
