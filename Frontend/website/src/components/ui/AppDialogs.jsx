import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { X, Plus, Play, ListPlus, Heart, Disc3, User, Share2, Info, Pencil, Trash2, Lock, Globe, Copy, Monitor, Speaker, Check, Bell, FolderPlus, ArrowUp, ArrowDown } from 'lucide-react';
import { useAppStore } from '../../store/useAppStore';
import { usePlayerStore } from '../../store/usePlayerStore';
import { useOverlayFocus } from '../../hooks/useOverlayFocus';
import { useCatalog } from '../../hooks/useCatalog';
import { useCatalogEntities } from '../../hooks/useCatalogEntities';
import { Notice, EmptyState } from './Screen';
import { playableTrack } from '../../utils/catalogEntities';

export function Modal({ title, description, onClose, children }) {
  const ref = useOverlayFocus(true, onClose);
  const titleId = React.useId();
  return <div className="ui-modal-backdrop" onClick={event => { if (event.target === event.currentTarget) onClose(); }}>
    <div ref={ref} className="ui-modal" role="dialog" aria-modal="true" aria-labelledby={titleId} tabIndex={-1}>
      <div className="ui-modal-header"><div><h2 id={titleId}>{title}</h2>{description && <p className="ui-muted mt-2">{description}</p>}</div><button className="ui-icon-button" onClick={onClose} aria-label="Đóng hộp thoại"><X size={18} /></button></div>{children}
    </div>
  </div>;
}

export function ImageField({ value, onChange, label = 'Ảnh bìa' }) {
  const [error, setError] = useState('');
  return <div className="flex flex-wrap items-center gap-4"><img src={value || '/images/catalog-placeholder.svg'} alt={label} className="w-20 h-20 rounded-xl object-cover" /><div className="flex-1 min-w-0"><label className="ui-label">{label}<input type="file" accept="image/png,image/jpeg,image/webp" className="ui-muted max-w-full" onChange={event => {
    const file = event.target.files?.[0]; if (!file) return;
    if (!['image/png','image/jpeg','image/webp'].includes(file.type) || file.size > 300000) { setError('Chọn ảnh PNG, JPG hoặc WebP dưới 300 KB.'); return; }
    const reader = new FileReader(); reader.onload = () => { onChange(reader.result); setError(''); }; reader.onerror = () => setError('Không đọc được ảnh. Hãy chọn lại.'); reader.readAsDataURL(file);
  }} /></label><p className="ui-muted mt-2">JPG, PNG, WebP · tối đa 300 KB</p>{error && <p role="alert" className="ui-error mt-2">{error}</p>}</div></div>;
}

function PlaylistEditor({ dialog, onClose }) {
  const navigate = useNavigate();
  const playlists = useAppStore(s => s.playlists);
  const source = playlists.find(item => item.id === dialog.playlistId);
  const [title, setTitle] = useState(source?.title || '');
  const [description, setDescription] = useState(source?.description || '');
  const [coverUrl, setCoverUrl] = useState(source?.coverUrl || '/images/catalog-placeholder.svg');
  const [error, setError] = useState('');
  const create = useAppStore(s => s.createPlaylist), update = useAppStore(s => s.updatePlaylist);
  return <Modal title={source ? 'Chỉnh sửa playlist' : 'Một playlist của riêng bạn'} description="Thêm một cái tên, một tấm ảnh và những giai điệu bạn yêu thích." onClose={onClose}>
    <form className="ui-form" onSubmit={event => { event.preventDefault(); if (!title.trim()) { setError('Hãy nhập tên playlist.'); return; } const values = { title: title.trim(), description: description.trim(), coverUrl }; const id = source ? (update(source.id, values), source.id) : create({ ...values, folderId: dialog.folderId || null }); onClose(); navigate(`/playlist/${id}`); }}>
      <ImageField value={coverUrl} onChange={setCoverUrl} />
      <label className="ui-label">Tên playlist<input className="ui-field" required maxLength={100} value={title} onChange={e => setTitle(e.target.value)} placeholder="Nhạc cho một chiều bình yên" /></label>
      <label className="ui-label">Mô tả<textarea className="ui-field" maxLength={500} value={description} onChange={e => setDescription(e.target.value)} placeholder="Kể một chút về tuyển tập này..." /></label>
      {error && <p role="alert" className="ui-error">{error}</p>}<div className="ui-actions justify-end"><button type="button" className="ui-button ui-button-ghost" onClick={onClose}>Hủy</button><button className="ui-button" type="submit">{source ? 'Lưu thay đổi' : 'Tạo playlist'}</button></div>
    </form>
  </Modal>;
}
function AddToPlaylist({ dialog, onClose }) {
  const songsData = useCatalog();
  const playlists = useAppStore(s => s.playlists), addTrack = useAppStore(s => s.addTrack), open = useAppStore(s => s.openDialog);
  const [query, setQuery] = useState('');
  const toast = usePlayerStore(s => s.setToast);
  const song = songsData.find(item => item.id === dialog.songId);
  const items = playlists.filter(item => item.owned && item.title.toLowerCase().includes(query.toLowerCase()));
  return <Modal title="Thêm vào playlist" description={song?.title} onClose={onClose}>
    <input className="ui-field mb-4" aria-label="Tìm playlist" value={query} onChange={e => setQuery(e.target.value)} placeholder="Tìm playlist của bạn" />
    <button className="ui-menu-item" onClick={() => open('playlist-editor')}><Plus />Tạo playlist mới</button>
    {!items.length && <p className="ui-muted py-6">Chưa có playlist phù hợp. Hãy tạo một tuyển tập của bạn.</p>}
    {items.map(item => <button key={item.id} className="ui-list-item w-full text-left" onClick={() => { const added = addTrack(item.id, dialog.songId); toast(added ? `Đã thêm vào ${item.title}` : 'Bài hát đã có trong playlist'); onClose(); }}><img src={item.coverUrl} alt="" /><div className="min-w-0 flex-1"><h3 className="truncate">{item.title}</h3><p>{item.songIds.length} bài hát</p></div>{item.songIds.includes(dialog.songId) ? <Check size={18} /> : <Plus size={18} />}</button>)}
  </Modal>;
}
function EditProfile({ onClose }) {
  const profile = useAppStore(s => s.profile), update = useAppStore(s => s.updateProfile);
  const [values, setValues] = useState(profile);
  return <Modal title="Chỉnh sửa hồ sơ" description="Một chút cá tính cho không gian âm nhạc của bạn." onClose={onClose}><form className="ui-form" onSubmit={e => { e.preventDefault(); if (!values.name.trim()) return; update({ ...values, name: values.name.trim() }); onClose(); }}>
    <ImageField label="Ảnh đại diện" value={values.avatar} onChange={avatar => setValues({ ...values, avatar })} />
    <label className="ui-label">Tên hiển thị<input className="ui-field" required maxLength={60} value={values.name} onChange={e => setValues({ ...values, name: e.target.value })} /></label>
    <label className="ui-label">Giới thiệu<textarea className="ui-field" maxLength={240} value={values.bio} onChange={e => setValues({ ...values, bio: e.target.value })} /></label><button className="ui-button">Lưu hồ sơ</button>
  </form></Modal>;
}
export function AppDialogs() {
  const dialog = useAppStore(s => s.dialog);
  if (!dialog) return null;
  return <DialogContent key={`${dialog.type}-${dialog.playlistId || dialog.songId || ''}`} dialog={dialog} />;
}
function DialogContent({ dialog }) {
  const { tracks: songsData, artists: artistsData, albums } = useCatalogEntities();
  const app = useAppStore();
  const player = usePlayerStore();
  const navigate = useNavigate();
  const onClose = app.closeDialog;
  const [name, setName] = useState('');
  const [query, setQuery] = useState('');
  const [deviceState, setDeviceState] = useState('ready');
  const song = songsData.find(item => item.id === dialog.songId);
  const playlist = app.playlists.find(item => item.id === dialog.playlistId);
  const copyLink = async href => { try { await navigator.clipboard.writeText(new URL(href, window.location.origin).href); player.setToast('Đã sao chép liên kết'); } catch { player.setToast('Không thể sao chép. Hãy dùng liên kết trên thanh địa chỉ.'); } };
  if (dialog.type === 'playlist-editor') return <PlaylistEditor dialog={dialog} onClose={onClose} />;
  if (dialog.type === 'add-to-playlist') return <AddToPlaylist dialog={dialog} onClose={onClose} />;
  if (dialog.type === 'edit-profile') return <EditProfile onClose={onClose} />;
  if (dialog.type === 'logout') return <Modal title="Đăng xuất khỏi bản trải nghiệm?" description="Playlist và hồ sơ vẫn được lưu trên trình duyệt này." onClose={onClose}><div className="ui-actions justify-end"><button className="ui-button ui-button-secondary" onClick={onClose}>Ở lại</button><button className="ui-button" onClick={() => { player.pause(); app.signOut(); navigate('/welcome'); }}>Đăng xuất</button></div></Modal>;
  if (dialog.type === 'clear-queue') return <Modal title="Xóa hàng đợi?" description="Bài đang phát được giữ lại; các bài xếp chờ sẽ bị xóa." onClose={onClose}><div className="ui-actions justify-end"><button className="ui-button ui-button-secondary" onClick={onClose}>Giữ lại</button><button className="ui-button ui-button-danger" onClick={() => { player.clearQueue(); onClose(); }}>Xóa hàng đợi</button></div></Modal>;
  if (dialog.type === 'signin') return <Modal title="Mang âm nhạc theo bạn" description="Đăng nhập bản trải nghiệm để tạo và quản lý playlist của riêng mình." onClose={onClose}><div className="ui-form"><Link className="ui-button" to={`/login?next=${encodeURIComponent(window.location.pathname)}`} onClick={onClose}>Đăng nhập</Link><Link className="ui-button ui-button-secondary" to="/signup" onClick={onClose}>Tạo tài khoản trải nghiệm</Link><Notice>Dữ liệu được lưu trên trình duyệt này. Chưa kết nối dịch vụ xác thực.</Notice></div></Modal>;
  if (dialog.type === 'song-menu' && song) {
    const album = albums.find(item => item.songIds.includes(song.id)), artist = artistsData.find(item => item.topTrackIds?.includes(song.id));
    return <Modal title={song.title} description={song.artist} onClose={onClose}>
      {playableTrack(song) && <button className="ui-menu-item" onClick={() => { player.playSong(song); onClose(); }}><Play />Phát ngay</button>}
      <button className="ui-menu-item" onClick={() => { player.toggleFavorite(song.id); onClose(); }}><Heart />{player.likedSongIds.includes(song.id) ? 'Bỏ yêu thích' : 'Thêm vào bài hát yêu thích'}</button>
      {playableTrack(song) && <button className="ui-menu-item" onClick={() => { player.addToQueue(song); onClose(); }}><ListPlus />Thêm vào hàng đợi</button>}
      <button className="ui-menu-item" onClick={() => app.openDialog(app.session ? 'add-to-playlist' : 'signin', { songId: song.id })}><Plus />Thêm vào playlist</button>
      {album && <Link className="ui-menu-item" to={`/album/${album.id}`} onClick={onClose}><Disc3 />Đi đến album</Link>}
      {artist && <Link className="ui-menu-item" to={`/artist/${artist.id}`} onClick={onClose}><User />Đi đến nghệ sĩ</Link>}
      <Link className="ui-menu-item" to={`/track/${song.id}`} onClick={onClose}><Info />Chi tiết và người thực hiện</Link>
      <button className="ui-menu-item" onClick={() => copyLink(`/track/${song.id}`)}><Share2 />Sao chép liên kết bài hát</button>
      {playlist?.owned && <button className="ui-menu-item text-sonara-link" onClick={() => { app.removeTrack(playlist.id, song.id); onClose(); }}><Trash2 />Xóa khỏi playlist này</button>}
    </Modal>;
  }
  if (dialog.type === 'playlist-menu' && playlist) return <Modal title={playlist.title} onClose={onClose}>
    {playlist.owned ? <>
      <button className="ui-menu-item" onClick={() => app.openDialog('playlist-editor', { playlistId: playlist.id })}><Pencil />Chỉnh sửa thông tin</button>
      <button className="ui-menu-item" onClick={() => { app.updatePlaylist(playlist.id, { isPublic: !playlist.isPublic }); onClose(); }}>{playlist.isPublic ? <Lock /> : <Globe />}{playlist.isPublic ? 'Chuyển thành riêng tư' : 'Chuyển thành công khai'}</button>
      <button className="ui-menu-item" onClick={() => app.openDialog('confirm-delete', { playlistId: playlist.id })}><Trash2 />Xóa playlist</button>
    </> : <button className="ui-menu-item" onClick={() => { if (!app.session) { app.openDialog('signin'); return; } const id = app.createPlaylist({ ...playlist, id: undefined, title: `${playlist.title} — Bản sao`, isPublic: false, owned: true, owner: app.profile.name }); onClose(); navigate(`/playlist/${id}`); }}><Copy />Tạo bản sao của bạn</button>}
    <button className="ui-menu-item" onClick={() => { app.toggleSaved('savedPlaylistIds', playlist.id); onClose(); }}><Heart />{app.savedPlaylistIds.includes(playlist.id) ? 'Bỏ lưu khỏi thư viện' : 'Lưu vào thư viện'}</button>
    <button className="ui-menu-item" onClick={() => copyLink(`/playlist/${playlist.id}`)}><Share2 />Sao chép liên kết</button>
    {playlist.owned && <label className="ui-label mt-4">Thư mục<select aria-label="Thư mục" className="ui-field" value={playlist.folderId || ''} onChange={e => app.updatePlaylist(playlist.id, { folderId: e.target.value || null })}><option value="">Không nằm trong thư mục</option>{app.folders.map(folder => <option key={folder.id} value={folder.id}>{folder.title}</option>)}</select></label>}
  </Modal>;
  if (dialog.type === 'confirm-delete' && playlist) return <Modal title="Xóa playlist?" description={`“${playlist.title}” sẽ bị xóa khỏi dữ liệu trên trình duyệt này.`} onClose={onClose}><div className="ui-actions justify-end"><button className="ui-button ui-button-secondary" onClick={onClose}>Giữ lại</button><button className="ui-button ui-button-danger" onClick={() => { app.deletePlaylist(playlist.id); onClose(); navigate('/library'); }}>Xóa playlist</button></div></Modal>;
  if (dialog.type === 'folder') return <Modal title="Tạo thư mục playlist" onClose={onClose}><form className="ui-form" onSubmit={e => { e.preventDefault(); if (!name.trim()) return; app.createFolder(name.trim()); onClose(); }}><label className="ui-label">Tên thư mục<input className="ui-field" required maxLength={60} value={name} onChange={e => setName(e.target.value)} placeholder="Những ngày bình yên" /></label><button className="ui-button"><FolderPlus size={16} />Tạo thư mục</button></form></Modal>;
  if (dialog.type === 'add-tracks' && playlist?.owned) return <Modal title="Thêm nhạc cho playlist" description={playlist.title} onClose={onClose}><input className="ui-field mb-4" aria-label="Tìm bài để thêm" value={query} onChange={e => setQuery(e.target.value)} placeholder="Tìm bài hát hoặc nghệ sĩ" />{songsData.filter(item => `${item.title} ${item.artist}`.toLowerCase().includes(query.toLowerCase())).map(item => <div className="ui-list-item" key={item.id}><img src={item.coverUrl} alt="" /><div className="min-w-0 flex-1"><h3>{item.title}</h3><p>{item.artist}</p></div><button className="ui-icon-button" disabled={playlist.songIds.includes(item.id)} aria-label={`Thêm ${item.title}`} onClick={() => app.addTrack(playlist.id, item.id)}>{playlist.songIds.includes(item.id) ? <Check size={17} /> : <Plus size={17} />}</button></div>)}</Modal>;
  if (dialog.type === 'reorder' && playlist?.owned) return <Modal title="Sắp xếp bài hát" description="Dùng nút lên / xuống để đổi thứ tự." onClose={onClose}>{playlist.songIds.map((id, index) => { const item = songsData.find(track => track.id === id); return item && <div className="ui-list-item" key={id}><span className="ui-muted">{index + 1}</span><h3 className="min-w-0 flex-1">{item.title}</h3><button className="ui-icon-button" disabled={index === 0} aria-label={`Chuyển ${item.title} lên`} onClick={() => app.moveTrack(playlist.id, index, -1)}><ArrowUp size={16} /></button><button className="ui-icon-button" disabled={index === playlist.songIds.length - 1} aria-label={`Chuyển ${item.title} xuống`} onClick={() => app.moveTrack(playlist.id, index, 1)}><ArrowDown size={16} /></button></div>; })}<button className="ui-button mt-5 w-full" onClick={onClose}>Xong</button></Modal>;
  if (dialog.type === 'devices') return <Modal title="Bạn muốn nghe ở đâu?" description="Âm thanh hiện được phát trên trình duyệt này." onClose={onClose}><div className="ui-panel flex items-center gap-4 mb-5"><Monitor className="text-sonara-link" /><div className="flex-1"><h3 className="font-bold text-sm">Trình duyệt này</h3><p className="ui-muted">Thiết bị phát hiện tại</p></div><Check size={18} className="text-sonara-success" /></div><Notice>Chưa kết nối dịch vụ phát đa thiết bị. Không có âm thanh nào được chuyển sang loa khác.</Notice><button className="ui-menu-item mt-3" onClick={() => setDeviceState('empty')}><Speaker />Tìm thiết bị khác</button>{deviceState === 'empty' && <EmptyState title="Chưa tìm thấy thiết bị" description="Kết nối thiết bị sẽ khả dụng khi dịch vụ phát đa thiết bị được triển khai." />}</Modal>;
  if (dialog.type === 'notifications') return <Modal title="Thông báo của bạn" onClose={onClose}>{app.notifications.slice(0, 3).map(item => <Link key={item.id} to={item.href} className="ui-list-item" onClick={() => { app.markRead(item.id); onClose(); }}><Bell size={20} className="text-sonara-link shrink-0" /><div><h3>{item.title}{!item.read && ' · Mới'}</h3><p>{item.description}</p></div></Link>)}<Link className="ui-text-link mt-6" to="/notifications" onClick={onClose}>Xem tất cả thông báo</Link></Modal>;
  return <Modal title="Tính năng đang được chuẩn bị" onClose={onClose}><Notice>Phần này chưa có kết nối dịch vụ. Bạn có thể tiếp tục khám phá nhạc trong bản trải nghiệm.</Notice></Modal>;
}
