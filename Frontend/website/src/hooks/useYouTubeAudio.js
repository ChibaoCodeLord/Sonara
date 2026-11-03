import { useEffect, useState } from 'react';
import { usePlayerStore } from '../store/usePlayerStore';
import { useAppStore } from '../store/useAppStore';
import { audioJob, forAudioPlayback } from '../utils/audioCatalog';

export function useYouTubeAudio() {
  const song = usePlayerStore(state => state.currentSong);
  const playing = usePlayerStore(state => state.isPlaying);
  const [status, setStatus] = useState(null);
  const [attempt, setAttempt] = useState(0);
  const videoId = ['youtube', 'youtube-audio'].includes(song?.provider) && !song.audioUrl ? song.youtubeId : null;
  useEffect(() => {
    if (!videoId || !playing) return;
    let stopped = false, timer; const controller = new AbortController();
    const fail = error => {
      if (stopped || error.name === 'AbortError' || usePlayerStore.getState().currentSong?.youtubeId !== videoId) return;
      setStatus({ videoId, error: error.message || 'Chưa chuẩn bị được audio.' });
      usePlayerStore.getState().pause();
      usePlayerStore.getState().setToast(error.message || 'Chưa chuẩn bị được audio.');
    };
    const accept = job => {
      if (stopped) return;
      if (job.status === 'ready' && job.track?.audioUrl) {
        const cached = { audioUrl: job.track.audioUrl, durationSeconds: job.track.durationSeconds, mediaJobId: job.id };
        useAppStore.getState().cacheAudio(videoId, cached);
        usePlayerStore.setState(state => ({
          currentSong: state.currentSong?.youtubeId === videoId ? forAudioPlayback(state.currentSong, cached) : state.currentSong,
          queue: state.queue.map(item => item.youtubeId === videoId ? forAudioPlayback(item, cached) : item)
        }));
        setStatus(null); return;
      }
      if (['failed', 'cancelled'].includes(job.status)) { fail(new Error(job.error || 'Không tải được audio.')); return; }
      setStatus({ videoId, progress: job.progress || 0 });
      timer = setTimeout(() => audioJob(`/jobs/${job.id}`, { signal: controller.signal }).then(accept).catch(fail), 1000);
    };
    audioJob('', { method: 'POST', body: JSON.stringify({ youtubeId: videoId }), signal: controller.signal }).then(accept).catch(fail);
    return () => { stopped = true; clearTimeout(timer); controller.abort(); };
  }, [videoId, playing, attempt]);
  const relevant = status?.videoId === videoId ? status : null;
  return { status: videoId && playing ? relevant || { progress: 0 } : videoId && relevant?.error ? relevant : null, retry: () => { setStatus(null); setAttempt(value => value + 1); usePlayerStore.getState().resume(); } };
}
