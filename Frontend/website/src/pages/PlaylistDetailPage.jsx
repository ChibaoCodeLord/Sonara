import React, { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { Play, Pause, Shuffle, Heart, MoreHorizontal, Plus, ArrowUpDown, Lock, Globe, Mic, Search } from 'lucide-react';
import { useAppStore } from '../store/useAppStore';
import { usePlayerStore } from '../store/usePlayerStore';
import { useCatalog } from '../hooks/useCatalog';
import { TrackRow } from '../components/ui/TrackRow';
import { SectionHeading, EmptyState, NotFound } from '../components/ui/Screen';
import { formatTime } from '../utils/formatters';

export function PlaylistDetailPage() {
  const songsData = useCatalog();
  const { id } = useParams();
  const app = useAppStore();
  const currentSong = usePlayerStore(s => s.currentSong), isPlaying = usePlayerStore(s => s.isPlaying), play = usePlayerStore(s => s.playSong), setQueue = usePlayerStore(s => s.setQueue), togglePlay = usePlayerStore(s => s.togglePlay), shuffleQueue = usePlayerStore(s => s.shuffleQueue), likes = usePlayerStore(s => s.likedSongIds), hum = usePlayerStore(s => s.toggleHumModal);
  const [query, setQuery] = useState('');
  const isLiked = id === 'playlist_liked_songs';
  const playlist = isLiked ? { id, title:'Bài hát yêu thích', description:'Những giai điệu bạn đã đánh dấu để nghe lại bất cứ khi nào.', coverUrl:'/images/catalog-placeholder.svg', songIds: likes, owner:app.profile.name, isPublic:false } : app.playlists.find(item => item.id === id);
  if (!playlist) return <NotFound title="Không tìm thấy danh sách phát" />;
  if (playlist.owned && !playlist.isPublic && !app.session) return <EmptyState title="Playlist này đang riêng tư" description="Đăng nhập bản trải nghiệm để mở playlist của bạn trên trình duyệt này."><Link className="ui-button" to={`/login?next=${encodeURIComponent(`/playlist/${id}`)}`}>Đăng nhập</Link></EmptyState>;
  const tracks = playlist.songIds.map(songId => songsData.find(song => song.id === songId)).filter(Boolean);
  const filtered = tracks.filter(song => `${song.title} ${song.artist}`.toLowerCase().includes(query.toLowerCase()));
  const active = tracks.some(song => song.id === currentSong?.id) && isPlaying;
  const recommended = songsData.filter(song => !playlist.songIds.includes(song.id)).slice(0,4);
  return <div className="ui-page"><div className="ui-split-hero"><img src={playlist.coverUrl} alt={playlist.title} /><div className="min-w-0"><p className="ui-eyebrow">{isLiked ? 'THƯ VIỆN CỦA BẠN' : playlist.owned ? 'PLAYLIST CỦA BẠN' : 'SONARA TUYỂN CHỌN'}</p><h1>{playlist.title}</h1><p className="ui-description">{playlist.description || playlist.subtitle || 'Một tuyển tập được tạo từ những giai điệu yêu thích.'}</p><div className="ui-actions mt-4 ui-muted"><Link className="text-sonara-text hover:underline" to={`/user/${playlist.owned || isLiked ? 'me' : 'sonara'}`}>{playlist.owner}</Link><span>· {tracks.length} bài · {formatTime(tracks.reduce((sum,song) => sum+song.durationSeconds,0))}</span>{playlist.owned && <span className="flex items-center gap-1">{playlist.isPublic ? <Globe size={13} /> : <Lock size={13} />}{playlist.isPublic ? 'Công khai' : 'Riêng tư'}</span>}</div></div></div>
    <div className="ui-actions"><button disabled={!tracks.length} className="ui-button" title={active ? 'Tạm dừng playlist' : 'Phát tất cả'} onClick={() => active ? togglePlay() : setQueue(tracks)}>{active ? <Pause size={18} /> : <Play size={18} fill="currentColor" />}{active ? 'Tạm dừng' : 'Phát tất cả'}</button><button className="ui-icon-button" title="Trộn thông minh" disabled={!tracks.length} onClick={() => shuffleQueue(tracks)}><Shuffle size={19} /></button>{!isLiked && <><button className="ui-icon-button" title="Yêu thích playlist" aria-pressed={app.savedPlaylistIds.includes(id)} onClick={() => app.toggleSaved('savedPlaylistIds', id)}><Heart size={19} fill={app.savedPlaylistIds.includes(id) ? 'currentColor' : 'none'} /></button><button className="ui-icon-button" aria-label="Tùy chọn playlist" onClick={() => app.openDialog('playlist-menu', { playlistId:id })}><MoreHorizontal size={20} /></button></>}{playlist.owned && <><button className="ui-button ui-button-secondary" onClick={() => app.openDialog('add-tracks', { playlistId:id })}><Plus size={17} />Thêm bài hát</button><button className="ui-button ui-button-ghost" disabled={tracks.length < 2} onClick={() => app.openDialog('reorder', { playlistId:id })}><ArrowUpDown size={16} />Đổi thứ tự</button></>}<button className="ui-button ui-button-ghost ml-auto" onClick={() => hum(true)}><Mic size={16} />Tìm bằng giai điệu</button></div>
    <section><SectionHeading title="Danh sách bài hát"><label className="relative w-full sm:w-64"><Search size={16} className="absolute left-3 top-3.5 text-sonara-muted" /><input className="ui-field pl-9 text-xs" aria-label="Tìm trong playlist" placeholder="Tìm trong playlist" value={query} onChange={e => setQuery(e.target.value)} /></label></SectionHeading><div className="ui-panel p-2">{filtered.map((song,index) => <TrackRow key={song.id} song={song} index={index} playlistId={id} onPlay={() => play(song)} />)}{!filtered.length && <EmptyState title={query ? 'Chưa tìm thấy bài phù hợp' : 'Playlist đang chờ những giai điệu đầu tiên'} description={isLiked ? 'Nhấn biểu tượng trái tim để thêm bài hát yêu thích.' : 'Thêm vài bài hát để bắt đầu một tuyển tập của riêng bạn.'}>{playlist.owned && <button className="ui-button" onClick={() => app.openDialog('add-tracks', { playlistId:id })}>Tìm và thêm nhạc</button>}</EmptyState>}</div></section>
    {playlist.owned && recommended.length > 0 && <section><SectionHeading title="Thêm một chút cảm hứng" /><div className="ui-panel">{recommended.map(song => <div key={song.id} className="ui-list-item"><img src={song.coverUrl} alt="" /><div className="min-w-0 flex-1"><h3>{song.title}</h3><p>{song.artist}</p></div><button className="ui-button ui-button-secondary" onClick={() => app.addTrack(id,song.id)}><Plus size={15} />Thêm</button></div>)}</div></section>}
  </div>;
}
