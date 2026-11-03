import React, { useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { Play } from 'lucide-react';
import { useCatalog } from '../hooks/useCatalog';
import { useRemoteCatalogStore } from '../store/useRemoteCatalogStore';
import { usePlayerStore } from '../store/usePlayerStore';
import { PageHeading, EmptyState } from '../components/ui/Screen';
import { CatalogState } from '../components/ui/CatalogState';
import { YouTubeTrackCard } from '../components/ui/YouTubeTrackCard';
import { sourceLabels, playableTrack } from '../utils/catalogEntities';
import { useCatalogCrawlStatus } from '../hooks/useCatalogCrawlStatus';

const normalize = v => v.normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[đĐ]/g,'d').toLowerCase();
export function YouTubeCatalogPage() {
  const catalog = useCatalog();
  const crawl=useCatalogCrawlStatus();
  const status = useRemoteCatalogStore(s => s.status), reload = useRemoteCatalogStore(s => s.load);
  const [params,setParams] = useSearchParams();
  const [visible,setVisible] = useState(48);
  const source = params.get('source') || 'all', region = params.get('region') || 'all', kind = params.get('kind') || 'all', query = params.get('q') || '';
  const update = values => { const next = new URLSearchParams(params); for (const [k,v] of Object.entries(values)) { if (v && v !== 'all') next.set(k,v); else next.delete(k); } setParams(next,{replace:true}); setVisible(48); };
  const tracks = catalog.filter(t => (source === 'all' || t.metadataSource === source) && (region === 'all' || t.region === region) &&
    (kind === 'all' || t.playbackKind === kind) && normalize(`${t.title} ${t.artist} ${t.album} ${t.genre || ''}`).includes(normalize(query)));
  const playable = tracks.filter(playableTrack);
  const hasVN = catalog.some(t => t.region === 'VN');
  const regionOptions = [['all', 'Mọi khu vực'], ...(hasVN ? [['VN', 'Nhạc Việt']] : []), ['INTL', 'Quốc tế']];
  return <div className="ui-page"><PageHeading eyebrow="CATALOG ÂM NHẠC" title="Nghe nhạc" description="Bản thu và metadata từ các nguồn âm nhạc. Bài có audio, preview và thông tin được ghi rõ trên từng thẻ."><button className="ui-button" disabled={!playable.length} onClick={() => usePlayerStore.getState().setQueue(playable)}><Play size={17} />Phát các bài có audio</button></PageHeading>
    <CatalogState />
    {crawl?.running&&<p className="ui-notice" role="status">Đang bổ sung audio YouTube: {crawl.totalAudio}/{crawl.target} bài trong catalog · {crawl.converted} MP3 đã chuyển đổi và kiểm tra.</p>}
    <div className="ui-actions" aria-label="Nguồn nhạc"><button className="ui-chip" aria-pressed={source === 'all'} onClick={() => update({source:'all'})}>Mọi nguồn</button>{[...new Set(catalog.map(t => t.metadataSource).filter(Boolean))].sort().map(s => <button key={s} className="ui-chip" aria-pressed={source === s} onClick={() => update({source:s})}>{sourceLabels[s] || s}</button>)}</div>
    <div className="ui-actions" aria-label="Loại nội dung">{[['all','Tất cả'],['full','Có audio'],['preview','Có preview tại nguồn'],['metadata','Chỉ thông tin']].map(([k,label]) => <button key={k} className="ui-chip" aria-pressed={kind === k} onClick={() => update({kind:k})}>{label}</button>)}</div>
    <div className="ui-actions" aria-label="Khu vực âm nhạc">{regionOptions.map(([k,label]) => <button key={k} className="ui-chip" aria-pressed={region === k} onClick={() => update({region:k})}>{label}</button>)}</div>
    <label className="ui-label">Tìm trong kho nhạc<input className="ui-field" value={query} placeholder="Tên bài hát, nghệ sĩ hoặc album" onChange={e => update({q:e.target.value})} /></label>
    <div className="ui-actions justify-between"><p className="ui-muted" aria-live="polite">{tracks.length} bản ghi · {playable.length} có audio</p><button className="ui-button ui-button-secondary" disabled={status === 'loading'} onClick={() => reload(true)}>Làm mới catalog</button></div>
    {tracks.length ? <div className="ui-grid">{tracks.slice(0,visible).map(t => <YouTubeTrackCard key={t.id} track={t} tracks={playableTrack(t) ? playable : [t]} index={playable.findIndex(p => p.id === t.id)} />)}</div> : status === 'ready' && <EmptyState title="Chưa có nội dung phù hợp" description="Thử thay từ khóa hoặc bộ lọc."><button className="ui-button" onClick={() => setParams({})}>Xóa bộ lọc</button></EmptyState>}
    {tracks.length > visible && <button className="ui-button ui-button-secondary" onClick={() => setVisible(n => n+48)}>Xem thêm ({Math.min(visible,tracks.length)}/{tracks.length})</button>}
  </div>;
}
