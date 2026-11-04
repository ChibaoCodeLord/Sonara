import {ApiError} from '../utils/apiError.js';

// Failed login attempts have a separate bucket from normal API traffic.
export function rateLimit({limit=100,windowMs=15*60*1000,failedOnly=false,skip=()=>false,now=Date.now}={}){
  const buckets=new Map();
  return (req,res,next)=>{
    if(skip(req))return next();
    const time=now();
    for(const [key,b]of buckets)if(b.until<=time&&b.pending===0)buckets.delete(key);
    const key=req.ip||req.socket.remoteAddress||'unknown';
    if(!buckets.has(key)&&buckets.size>=10000){res.set('Retry-After','60');return next(new ApiError(429,'Dịch vụ đang bận, hãy thử lại sau.'));}
    const b=buckets.get(key)||{count:0,pending:0,until:time+windowMs};buckets.set(key,b);
    if(b.count+b.pending>=limit){res.set('Retry-After',String(Math.max(1,Math.ceil((b.until-time)/1000))));return next(new ApiError(429,'Bạn đã gửi quá nhiều yêu cầu. Hãy thử lại sau.'));}
    if(failedOnly){
      b.pending++;let settled=false;
      const settle=()=>{if(settled)return;settled=true;b.pending--;if(res.statusCode===401||res.statusCode===403)b.count++;else if(res.statusCode<400)b.count=0;};
      res.once('finish',settle);res.once('close',settle);
    }else b.count++;
    next();
  };
}
