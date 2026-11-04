import React, { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { Play, Pause, Bookmark, Check, Headphones, RotateCcw } from 'lucide-react';
import { podcastsData, findEpisode } from '../data/catalog';
import { useAppStore } from '../store/useAppStore';
import { PageHeading, ContentCard, SectionHeading, NotFound, Notice } from '../components/ui/Screen';
import { formatTime } from '../utils/formatters';

export function PodcastsPage() {
  return <div className="ui-page"><PageHeading eyebrow="LẮNG NGHE NHỮNG CÂU CHUYỆN" title="Một góc dành cho podcast" description="Những ý tưởng, con người và câu chuyện phía sau các giai điệu." /><Notice>Nội dung và trình phát podcast đang là bản minh họa, chưa có bản ghi âm thực tế.</Notice><div className="ui-grid">{podcastsData.map(show => <ContentCard key={show.id} to={`/show/${show.id}`} title={show.title} subtitle={show.author} image={show.coverUrl} badge="PODCAST" />)}</div><section className="ui-panel"><SectionHeading title="Bắt đầu từ một câu chuyện" />{podcastsData.flatMap(show => show.episodes.map(episode => <Link className="ui-list-item" to={`/episode/${episode.id}`} key={episode.id}><img src={show.coverUrl} alt="" /><div className="min-w-0 flex-1"><h3>{episode.title}</h3><p>{show.title} · {Math.round(episode.duration/60)} phút</p></div><Play size={18} /></Link>))}</section></div>;
}
export function ShowPage() {
  const { id } = useParams();
  const show = podcastsData.find(item => item.id === id), followed = useAppStore(s => s.followedShowIds), toggle = useAppStore(s => s.toggleSaved);
  if (!show) return <NotFound title="Không tìm thấy podcast" />;
  return <div className="ui-page"><div className="ui-split-hero"><img src={show.coverUrl} alt={show.title} /><div className="min-w-0"><p className="ui-eyebrow">PODCAST · {show.category}</p><h1>{show.title}</h1><p className="ui-description">{show.description}</p><p className="ui-muted mt-4">{show.author} · {show.episodes.length} tập</p></div></div><div className="ui-actions"><button className="ui-button ui-button-secondary" aria-pressed={followed.includes(id)} onClick={() => toggle('followedShowIds', id)}>{followed.includes(id) ? <Check size={17} /> : <Headphones size={17} />}{followed.includes(id) ? 'Đang theo dõi' : 'Theo dõi podcast'}</button></div><section className="ui-panel"><SectionHeading title="Tất cả các tập" />{show.episodes.map(episode => <Link className="ui-list-item" key={episode.id} to={`/episode/${episode.id}`}><img src={show.coverUrl} alt="" /><div className="min-w-0 flex-1"><h3>{episode.title}</h3><p>{episode.description}</p><p>{episode.date} · {Math.round(episode.duration/60)} phút</p></div><Play size={18} /></Link>)}</section></div>;
}
export function EpisodePage() {
  const { id } = useParams();
  const episode = findEpisode(id);
  const duration = episode?.duration;
  const progress = useAppStore(s => s.episodeProgress[id] || 0), setProgress = useAppStore(s => s.setEpisodeProgress), saved = useAppStore(s => s.savedEpisodeIds), toggle = useAppStore(s => s.toggleSaved);
  const [playing, setPlaying] = useState(false), [speed, setSpeed] = useState(1);
  useEffect(() => {
    if (!playing || !duration) return;
    const timer = setInterval(() => { const current = useAppStore.getState().episodeProgress[id] || 0; const next = Math.min(duration, current + speed); setProgress(id, next); if (next >= duration) setPlaying(false); }, 1000);
    return () => clearInterval(timer);
  }, [playing, duration, id, setProgress, speed]);
  if (!episode) return <NotFound title="Không tìm thấy tập podcast" />;
  return <div className="ui-page"><div className="ui-split-hero"><img src={episode.show.coverUrl} alt={episode.show.title} /><div className="min-w-0"><Link className="ui-eyebrow block hover:underline" to={`/show/${episode.show.id}`}>{episode.show.title}</Link><h1>{episode.title}</h1><p className="ui-description">{episode.description}</p><p className="ui-muted mt-4">{episode.date} · {Math.round(episode.duration/60)} phút</p></div></div><Notice>Trình phát mô phỏng: không phát âm thanh, chỉ minh họa tiến trình, tốc độ và tiếp tục nghe.</Notice><section className="ui-panel"><div className="ui-actions mb-6"><button className="ui-button" onClick={() => setPlaying(!playing)}>{playing ? <Pause size={17} /> : <Play size={17} />}{playing ? 'Dừng mô phỏng' : progress > 0 ? 'Tiếp tục mô phỏng' : 'Bắt đầu mô phỏng'}</button><button className="ui-icon-button" aria-label="Lùi 15 giây" onClick={() => setProgress(id, Math.max(0, progress-15))}><RotateCcw size={18} /></button><label className="ui-label">Tốc độ<select aria-label="Tốc độ" className="ui-field py-2" value={speed} onChange={e => setSpeed(Number(e.target.value))}>{[.75,1,1.25,1.5,2].map(value => <option key={value} value={value}>{value}×</option>)}</select></label><button className="ui-button ui-button-secondary" aria-pressed={saved.includes(id)} onClick={() => toggle('savedEpisodeIds', id)}><Bookmark size={17} />{saved.includes(id) ? 'Đã lưu tập' : 'Lưu tập'}</button></div><input type="range" aria-label="Tiến trình podcast mô phỏng" min={0} max={episode.duration} value={progress} onChange={e => setProgress(id, Number(e.target.value))} className="w-full accent-rose-600" /><div className="flex justify-between ui-muted mt-3"><span>{formatTime(progress)}</span><span>{formatTime(episode.duration)}</span></div></section><section className="ui-panel"><SectionHeading title="Về tập này" /><p className="ui-description">{episode.description} {episode.show.description}</p><Link className="ui-text-link mt-5" to={`/show/${episode.show.id}`}>Khám phá các tập khác</Link></section></div>;
}
