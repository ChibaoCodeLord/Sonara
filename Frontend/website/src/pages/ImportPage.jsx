import React, { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { SquarePlay as Youtube, Headphones, ArrowRight, CheckCircle2, LoaderCircle, Link2, Play, ListPlus, Trash2, RefreshCw } from 'lucide-react';
import { PageHeading, EmptyState } from '../components/ui/Screen';
import { useAppStore } from '../store/useAppStore';
import { usePlayerStore } from '../store/usePlayerStore';
import { mediaRequest, validYoutubeLink } from '../utils/mediaApi';

const labels = { metadata: 'Đang đọc thông tin video', downloading: 'Đang tải âm thanh', converting: 'Đang chuyển sang MP3', ready: 'MP3 đã sẵn sàng', failed: 'Chuyển đổi thất bại', cancelled: 'Đã hủy chuyển đổi' };
const isActive = job => job && ['metadata', 'downloading', 'converting'].includes(job.status);
async function readHealth() {
  try { return await mediaRequest('/health'); }
  catch (error) { return { ready: false, message: error.message }; }
}
export function ImportPage() {
  const app = useAppStore(), player = usePlayerStore();
  const [url, setUrl] = useState(''), [job, setJob] = useState(null), [error, setError] = useState('');
  const [health, setHealth] = useState(null), [busy, setBusy] = useState(false), [removeId, setRemoveId] = useState(null);
  const mounted = useRef(false);
  const check = () => { setHealth(null); readHealth().then(result => { if (mounted.current) setHealth(result); }); };
  useEffect(() => {
    mounted.current = true;
    let disposed = false;
    readHealth().then(result => { if (!disposed) setHealth(result); });
    const id = useAppStore.getState().importJobs[0];
    if (id) mediaRequest(`/jobs/${id}`).then(result => { if (!disposed) setJob(result); }).catch(e => { if (!disposed && e.status !== 404) setError(e.message); });
    return () => { disposed = true; mounted.current = false; };
  }, []);
  const jobId = job?.id, jobStatus = job?.status, jobTrack = job?.track;
  useEffect(() => {
    if (!['metadata', 'downloading', 'converting'].includes(jobStatus)) return;
    const controller = new AbortController();
    let stopped = false, timer;
    const poll = async () => {
      try {
        const result = await mediaRequest(`/jobs/${jobId}`, { signal: controller.signal });
        if (!stopped) { setJob(result); setError(''); }
      } catch (e) { if (!stopped) setError(e.message); }
      if (!stopped) timer = setTimeout(poll, 1200);
    };
    timer = setTimeout(poll, 600);
    return () => { stopped = true; clearTimeout(timer); controller.abort(); };
  }, [jobId, jobStatus]);
  useEffect(() => { if (jobStatus === 'ready' && jobTrack) useAppStore.getState().saveImportedTrack(jobTrack); }, [jobStatus, jobTrack]);
  const submit = async event => {
    event.preventDefault(); setError('');
    if (!validYoutubeLink(url.trim())) { setError('Nhập liên kết HTTPS của một video YouTube, ví dụ https://www.youtube.com/watch?v=…'); return; }
    setBusy(true);
    try { const result = await mediaRequest('/jobs', { method: 'POST', body: JSON.stringify({ url: url.trim() }) }); if (mounted.current) { setJob(result); app.rememberImport(result.id); } }
    catch (e) { if (mounted.current) setError(e.message); }
    finally { if (mounted.current) setBusy(false); }
  };
  const cancel = async () => {
    setBusy(true);
    try { await mediaRequest(`/jobs/${job.id}`, { method: 'DELETE' }); setJob({ ...job, status: 'cancelled', error: 'Đã hủy chuyển đổi.' }); setError(''); }
    catch (e) { setError(e.message); } finally { setBusy(false); }
  };
  const remove = async track => {
    setBusy(true);
    try {
      await mediaRequest(`/jobs/${track.mediaJobId}`, { method: 'DELETE' }).catch(e => { if (e.status !== 404) throw e; });
      if (player.currentSong?.id === track.id) player.pause();
      player.forgetSong(track.id);
      useAppStore.setState(state => ({ importedTracks: state.importedTracks.filter(item => item.id !== track.id), importJobs: state.importJobs.filter(id => id !== track.mediaJobId), history: state.history.filter(item => item.songId !== track.id), playlists: state.playlists.map(item => item.owned ? { ...item, songIds: item.songIds.filter(id => id !== track.id) } : item) }));
      if (job?.id === track.mediaJobId) setJob(null);
      setRemoveId(null);
    } catch (e) { setError(e.message); } finally { setBusy(false); }
  };
  return <div className="ui-page"><PageHeading eyebrow="THƯ VIỆN CÁ NHÂN" title="YouTube → MP3" description="Dán liên kết video. Chuyển thành âm thanh và nghe ngay trong Sonara." />
    <section className="ui-panel import-hero"><div className="import-mark" aria-hidden="true"><Youtube size={32} /><ArrowRight size={20} /><Headphones size={32} /></div><h2>Mang giai điệu bạn tìm thấy về đây</h2><p className="ui-description">Một video mỗi lần · tối đa 30 phút · MP3 192 kbps</p>
      <form className="ui-form mt-6" onSubmit={submit}><label className="ui-label" htmlFor="youtube-url">Liên kết YouTube</label><div className="import-input-row"><div className="relative flex-1 min-w-0"><Link2 size={18} className="absolute top-3.5 left-3 text-sonara-muted" aria-hidden="true" /><input id="youtube-url" type="url" required maxLength={2048} autoComplete="off" className="ui-field pl-10" placeholder="https://www.youtube.com/watch?v=…" value={url} onChange={event => setUrl(event.target.value)} aria-describedby="import-help" disabled={busy || isActive(job)} /></div><button className="ui-button" disabled={busy || isActive(job)}>{busy ? <LoaderCircle className="animate-spin" size={18} /> : <Youtube size={18} />}Chuyển thành MP3</button></div><p id="import-help" className="ui-muted">Hỗ trợ youtube.com, youtu.be và YouTube Shorts. Không hỗ trợ playlist hoặc livestream.</p></form>
      <div className={`import-health ${health?.ready ? 'import-online' : ''}`} role="status">{health === null ? 'Đang kiểm tra dịch vụ chuyển đổi…' : health.ready ? 'Dịch vụ chuyển đổi đã kết nối' : health.message}<button className="ui-icon-button" aria-label="Kiểm tra lại dịch vụ" onClick={check}><RefreshCw size={15} /></button></div>
    </section>
    {error && <p className="ui-error ui-panel" role="alert">{error}</p>}
    {job && <section className="ui-panel import-job" aria-label="Trạng thái chuyển đổi"><div className="ui-section-heading"><div className="min-w-0"><p className="ui-eyebrow">{job.title || 'VIDEO YOUTUBE'}</p><h2 aria-live="polite">{labels[job.status]}</h2></div>{job.status === 'ready' ? <CheckCircle2 className="text-sonara-success shrink-0" /> : isActive(job) ? <LoaderCircle className="animate-spin shrink-0 text-sonara-link" /> : null}</div>{isActive(job) && <><progress max={100} value={job.progress} aria-label="Tiến trình chuyển đổi" /><p className="ui-muted mt-2">{job.status === 'metadata' ? 'Đang xác minh video…' : `${job.progress}% · ${job.status === 'converting' ? 'Đang mã hóa MP3' : 'Tiến trình tải âm thanh'}`}</p><button className="ui-button ui-button-secondary mt-4" disabled={busy} onClick={cancel}>Hủy chuyển đổi</button></>}{job.status === 'ready' && <div className="ui-actions"><button className="ui-button" onClick={() => player.playSong(job.track)}><Play size={17} />Nghe ngay</button><button className="ui-button ui-button-secondary" onClick={() => player.addToQueue(job.track)}><ListPlus size={17} />Thêm vào hàng đợi</button></div>}{['failed', 'cancelled'].includes(job.status) && <><p className="ui-muted">{job.error}</p><button className="ui-button ui-button-secondary mt-4" onClick={() => { setUrl(job.url); setJob(null); setError(''); }}>Thử lại video này</button></>}</section>}
    <section><div className="ui-section-heading"><h2>MP3 của bạn</h2><span className="ui-muted">{app.importedTracks.length} / 30 tệp</span></div>{app.importedTracks.length ? <div className="ui-panel p-2">{app.importedTracks.map(track => <div className="ui-list-item import-track" key={track.id}><img src={track.coverUrl} alt="" /><div className="min-w-0 flex-1"><Link className="font-bold text-sm block truncate" to={`/track/${track.id}`}>{track.title}</Link><p className="truncate">{track.artist} · MP3</p></div><button className="ui-icon-button" aria-label={`Phát ${track.title}`} onClick={() => player.playSong(track)}><Play size={17} /></button><button className="ui-icon-button" aria-label={`Thao tác ${track.title}`} onClick={() => app.openDialog('song-menu', { songId: track.id })}>•••</button><button className="ui-icon-button" aria-label={`Xóa ${track.title}`} onClick={() => setRemoveId(track.id)}><Trash2 size={17} /></button>{removeId === track.id && <div className="import-delete" role="alert"><p>Xóa tệp MP3 và gỡ bài khỏi playlist, yêu thích, lịch sử trên trình duyệt này?</p><div className="ui-actions"><button className="ui-button ui-button-danger" disabled={busy} onClick={() => remove(track)}>Xác nhận xóa MP3</button><button className="ui-button ui-button-secondary" disabled={busy} onClick={() => setRemoveId(null)}>Giữ lại</button></div></div>}</div>)}</div> : <EmptyState title="Chưa có MP3 nào" description="Bắt đầu bằng liên kết video đầu tiên của bạn." icon={Youtube} />}</section>
    <p className="ui-muted">Tệp MP3 lưu trên máy chạy dịch vụ Sonara; danh sách của bạn lưu trên trình duyệt. Cần bật dịch vụ để chuyển đổi và phát các tệp này.</p>
  </div>;
}
