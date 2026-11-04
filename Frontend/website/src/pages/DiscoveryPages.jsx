import React, { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { Play, Heart, MoreHorizontal } from 'lucide-react';
import { useAppStore } from '../store/useAppStore';
import { usePlayerStore } from '../store/usePlayerStore';
import { useCatalog } from '../hooks/useCatalog';
import { useCatalogEntities } from '../hooks/useCatalogEntities';
import { categoriesData } from '../data/catalog';
import { TrackRow } from '../components/ui/TrackRow';
import { CatalogState } from '../components/ui/CatalogState';
import { CategoryCard } from '../components/ui/CategoryCard';
import { PageHeading, SectionHeading, ContentCard, NotFound, EmptyState, Notice } from '../components/ui/Screen';
import { formatTime } from '../utils/formatters';
import { useRemoteCatalogStore } from '../store/useRemoteCatalogStore';
import { playableTrack, playbackLabel, sourceLabels } from '../utils/catalogEntities';

export function AlbumPage() {
  const { tracks, albums } = useCatalogEntities();
  const status = useRemoteCatalogStore(s => s.status);
  const { id } = useParams(); const album = albums.find(a => a.id === id);
  const saved = useAppStore(s => s.savedAlbumIds), toggle = useAppStore(s => s.toggleSaved);
  const queue = usePlayerStore(s => s.setQueue), play = usePlayerStore(s => s.playSong);
  if (!album) return status === 'ready' ? <NotFound title="Không tìm thấy album" /> : <CatalogState />;
  const songs = tracks.filter(t => album.songIds.includes(t.id));
  return <div className="ui-page"><div className="ui-split-hero"><img src={album.coverUrl} alt="" /><div className="min-w-0"><p className="ui-eyebrow">{album.type} · {album.year} · {sourceLabels[album.source]}</p><h1>{album.title}</h1><p className="ui-description">{album.artist}</p><p className="ui-muted mt-4">{songs.length} bản ghi trong catalog</p></div></div>
    <div className="ui-actions"><button className="ui-button" disabled={!songs.some(playableTrack)} onClick={() => queue(songs.filter(playableTrack))}><Play size={17} />Phát các bài có audio</button><button className="ui-button ui-button-secondary" aria-pressed={saved.includes(id)} onClick={() => toggle('savedAlbumIds',id)}><Heart size={17} />{saved.includes(id) ? 'Đã lưu album' : 'Lưu album'}</button></div>
    <section><SectionHeading title="Danh sách bản thu" /><div className="ui-panel p-2">{songs.map((song,index) => <TrackRow key={song.id} song={song} index={index} onPlay={() => play(song)} />)}</div></section>
  </div>;
}
export function TrackDetailPage() {
  const { tracks, albums } = useCatalogEntities();
  const status = useRemoteCatalogStore(s => s.status);
  const { id } = useParams(); const song = tracks.find(t => t.id === id);
  const play = usePlayerStore(s => s.playSong), open = useAppStore(s => s.openDialog);
  if (!song) return status === 'ready' ? <NotFound title="Không tìm thấy bài hát" /> : <CatalogState />;
  const album = albums.find(a => a.songIds.includes(id));
  return <div className="ui-page"><div className="ui-split-hero"><img src={song.coverUrl} alt="" /><div className="min-w-0"><p className="ui-eyebrow">{sourceLabels[song.metadataSource] || 'ÂM NHẠC'} · {playbackLabel(song)}</p><h1>{song.title}</h1><p className="ui-description">{song.artist}</p><p className="ui-muted mt-3">{song.durationSeconds ? formatTime(song.durationSeconds) : 'Chưa rõ thời lượng'}{song.contentKind === 'music_candidate' ? ' · Bản thu / ví dụ âm nhạc' : ''}</p></div></div>
    <div className="ui-actions">{playableTrack(song) && <button className="ui-button" onClick={() => play(song)}><Play size={17} />Phát audio</button>}{song.sourceUrl && <a className="ui-button ui-button-secondary" href={song.sourceUrl} target="_blank" rel="noreferrer">{song.playbackKind === 'preview' ? 'Nghe thử tại nguồn ↗' : 'Mở nguồn gốc ↗'}</a>}<button className="ui-icon-button" aria-label="Thao tác bài hát" onClick={() => open('song-menu',{songId:id})}><MoreHorizontal size={18} /></button></div>
    <div className="ui-two-column"><section className="ui-panel"><SectionHeading title="Lời bài hát" />{song.lyrics?.length ? song.lyrics.map((line,index) => <p key={index}>{line.text}</p>) : <p className="ui-muted">Chưa có lời bài hát được xác nhận.</p>}{!playableTrack(song) && <p className="ui-notice mt-5">{song.playbackKind === 'preview' ? 'Nguồn có bản nghe thử; catalog không cung cấp audio đầy đủ cho bản ghi này.' : 'Bản ghi này chỉ có metadata, chưa có audio để phát.'}</p>}</section>
      <section className="ui-panel"><SectionHeading title="Thông tin bản thu" />{song.artists?.map(a => <Link className="ui-text-link block mt-2" key={a.id} to={`/artist/${a.id}`}>{a.name}</Link>)}{album && <Link className="ui-text-link block mt-3" to={`/album/${album.id}`}>Album: {album.title}</Link>}{song.licenseUrl && <a className="ui-text-link block mt-3" href={song.licenseUrl} target="_blank" rel="noreferrer">Giấy phép: {song.licenseLabel || 'Xem điều khoản'} ↗</a>}{song.metadataSource === 'discogs' && <p className="ui-muted mt-3">Data provided by Discogs.</p>}</section>
    </div>
  </div>;
}
export function BrowsePage() {
  useCatalog();
  return <div className="ui-page"><PageHeading title="Khám phá âm nhạc" description="Tìm bản thu theo thể loại hoặc xem toàn bộ catalog." /><Link className="ui-button self-start" to="/youtube">Mở toàn bộ kho nhạc</Link><div className="ui-grid">{categoriesData.map(c => <CategoryCard key={c.id} title={c.title} subtitle={c.subtitle} image={c.image} color={c.color} to={`/category/${c.id}`} />)}</div></div>;
}
export function CategoryPage() {
  const tracks = useCatalog(); const { id } = useParams();
  const category = categoriesData.find(c => c.id === id); const play = usePlayerStore(s => s.playSong);
  if (!category) return <NotFound title="Không tìm thấy thể loại" />;
  const songs = tracks.filter(t => category.terms.some(term => t.genre?.toLowerCase().includes(term.toLowerCase())));
  return <div className="ui-page"><PageHeading title={category.title} description={category.subtitle} /><CatalogState />{songs.length ? <div className="ui-panel p-2">{songs.map((song,index) => <TrackRow key={song.id} song={song} index={index} onPlay={() => play(song)} />)}</div> : <EmptyState title="Chưa có bản thu thuộc thể loại này" />}</div>;
}
export function CollectionPage() {
  const { tracks, artists, albums } = useCatalogEntities(); const { id } = useParams();
  const playlists = useAppStore(s => s.playlists), play = usePlayerStore(s => s.playSong);
  const titles = { mixes:'Danh sách phát', albums:'Bản phát hành', artists:'Nghệ sĩ & người đóng góp', recommended:'Khám phá bản thu', trending:'Các bản thu có audio' };
  if (!titles[id]) return <NotFound />;
  const songs = id === 'trending' ? tracks.filter(playableTrack) : tracks;
  return <div className="ui-page"><PageHeading title={titles[id]} /><CatalogState />{['recommended','trending'].includes(id) ? <div className="ui-panel p-2">{songs.map((song,index) => <TrackRow key={song.id} song={song} index={index} onPlay={() => play(song)} />)}</div> : <div className="ui-grid">{id === 'albums' ? albums.map(a => <ContentCard key={a.id} to={`/album/${a.id}`} title={a.title} subtitle={a.artist} image={a.coverUrl} />) : id === 'artists' ? artists.map(a => <ContentCard key={a.id} to={`/artist/${a.id}`} title={a.name} subtitle={sourceLabels[a.source]} image={a.avatarUrl} round />) : playlists.map(p => <ContentCard key={p.id} to={`/playlist/${p.id}`} title={p.title} subtitle={p.description} image={p.coverUrl} />)}</div>}{id === 'mixes' && !playlists.length && <EmptyState title="Chưa có danh sách phát" description="Bạn có thể tạo playlist trong thư viện." />}</div>;
}
export function HistoryPage() {
  const tracks = useCatalog(); const history = useAppStore(s => s.history), clear = useAppStore(s => s.clearHistory), play = usePlayerStore(s => s.playSong);
  const [confirm,setConfirm] = useState(false); const entries = history.map(h => tracks.find(t => t.id === h.songId)).filter(Boolean);
  return <div className="ui-page"><PageHeading title="Nghe gần đây" description="Các bản thu bạn đã phát trên trình duyệt này.">{entries.length > 0 && <button className="ui-button ui-button-secondary" onClick={() => setConfirm(true)}>Xóa lịch sử</button>}</PageHeading>{history.some(item => item.isTestData) && <Notice>Danh sách có lịch sử nghe mô phỏng từ bộ dữ liệu kiểm thử. Các mục này không tạo chuỗi nghe nhạc.</Notice>}{confirm && <div className="ui-panel" role="alert"><p>Xóa lịch sử nghe?</p><button className="ui-button" onClick={() => {clear();setConfirm(false);}}>Xác nhận xóa</button><button className="ui-button ui-button-secondary" onClick={() => setConfirm(false)}>Hủy</button></div>}{entries.length ? <div className="ui-panel p-2">{entries.map((song,index) => <TrackRow key={song.id} song={song} index={index} onPlay={() => play(song)} />)}</div> : <EmptyState title="Chưa có bài hát gần đây" />}</div>;
}
export function NotificationsPage() {
  const items = useAppStore(s => s.notifications), mark = useAppStore(s => s.markRead);
  return <div className="ui-page"><PageHeading title="Thông báo" />{items.length ? <div className="ui-panel">{items.map(n => <Link className="ui-list-item" key={n.id} to={n.href} onClick={() => mark(n.id)}>{n.title}</Link>)}</div> : <EmptyState title="Chưa có thông báo" />}</div>;
}
export function PublicProfilePage() {
  const { id } = useParams(); const profile = useAppStore(s => s.profile), session = useAppStore(s => s.session), playlists = useAppStore(s => s.playlists);
  if (id !== 'me') return <NotFound title="Không tìm thấy người dùng" />;
  if (!session) return <EmptyState title="Đăng nhập để xem hồ sơ"><Link className="ui-button" to="/login">Đăng nhập</Link></EmptyState>;
  return <div className="ui-page"><PageHeading title={profile.name} description={profile.bio} /><div className="ui-grid">{playlists.filter(p => p.owned && p.isPublic).map(p => <ContentCard key={p.id} to={`/playlist/${p.id}`} title={p.title} image={p.coverUrl} />)}</div></div>;
}
