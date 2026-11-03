import { useEffect, useState } from 'react';
import { useRemoteCatalogStore } from '../store/useRemoteCatalogStore';

export function useCatalogCrawlStatus(){
  const [status,setStatus]=useState(null);
  useEffect(()=>{
    let disposed=false,timer,lastTotal;
    const sync=async()=>{
      try{
        const base=import.meta.env.VITE_CATALOG_API_URL||'/api/v1/catalog';
        const response=await fetch(`${base}/crawl-status`,{cache:'no-store',signal:AbortSignal.timeout(10000)});
        if(response.ok){
          const {data}=await response.json();
          if(!disposed){setStatus(data);if(lastTotal!==undefined&&lastTotal!==data.totalAudio)await useRemoteCatalogStore.getState().load(true);lastTotal=data.totalAudio;}
        }
      }catch{/* A crawl status outage must not interrupt the music catalog. */}
      if(!disposed)timer=setTimeout(sync,30000);
    };
    sync();return()=>{disposed=true;clearTimeout(timer);};
  },[]);
  return status;
}
