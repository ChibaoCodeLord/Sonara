import { useCallback, useEffect, useRef } from 'react';
import { usePlayerStore } from '../store/usePlayerStore';
import { useAppStore } from '../store/useAppStore';
import { playbackInterval } from '../utils/listeningActivity';

export function useAudioEngine() {
  const audioRef = useRef(null);
  const sourceIdRef = useRef(null);

  const seek = useCallback(seconds => {
    if (!Number.isFinite(seconds)) return;
    const state = usePlayerStore.getState();
    const time = Math.max(0, Math.min(seconds, state.duration));
    if (audioRef.current && state.currentSong?.provider !== 'youtube' && Number.isFinite(audioRef.current.duration)) audioRef.current.currentTime = time;
    state.seekTo(time);
  }, []);

  useEffect(() => {
    const audio = new Audio();
    audio.preload = 'metadata';
    audioRef.current = audio;
    const state = () => usePlayerStore.getState();
    let previousSample = null;
    const samplePlayback = () => {
      const sample = { wall: Date.now(), media: audio.currentTime, active: !audio.paused && !audio.seeking && audio.readyState >= 2 };
      const interval = playbackInterval(previousSample, sample);
      if (interval) useAppStore.getState().recordListening(...interval);
      previousSample = sample;
    };
    const resetSample = () => { previousSample = null; };
    const playbackTimer = window.setInterval(samplePlayback, 1000);
    const failPlayback = () => {
      if (!state().isPlaying || !state().currentSong?.audioUrl || state().currentSong?.provider === 'youtube') return;
      state().pause();
      state().setToast('Không thể phát tệp âm thanh này. Hãy thử lại hoặc chọn bài khác.');
    };
    const play = () => { const expectedSource = sourceIdRef.current; audio.play().catch(() => { if (expectedSource === sourceIdRef.current) failPlayback(); }); };
    const recordPlayback = () => { const song = state().currentSong; if (song?.id && song.audioUrl && song.provider !== 'youtube') useAppStore.getState().recordListen(song.id); };
    const timeupdate = () => {
      if (state().currentSong?.audioUrl && Number.isFinite(audio.duration)) state().setCurrentTime(Math.floor(audio.currentTime));
    };
    const metadata = () => {
      if (!state().currentSong?.audioUrl || !Number.isFinite(audio.duration)) return;
      const duration = Math.floor(audio.duration);
      state().setDuration(duration);
      const time = Math.min(state().currentTime, duration);
      audio.currentTime = time;
      state().setCurrentTime(time);
    };
    const ended = () => {
      if (state().repeatMode === 'one') { seek(0); play(); }
      else state().nextSong({ automatic: true });
    };
    audio.addEventListener('timeupdate', timeupdate);
    audio.addEventListener('loadedmetadata', metadata);
    audio.addEventListener('ended', ended);
    audio.addEventListener('error', failPlayback);
    audio.addEventListener('playing', recordPlayback);
    for (const event of ['seeking', 'waiting', 'pause', 'ended', 'emptied']) audio.addEventListener(event, resetSample);

    const sync = (next, previous) => {
      const sourceKey = `${next.currentSong?.id || ''}|${next.currentSong?.audioUrl || ''}`;
      const sourceChanged = sourceIdRef.current !== sourceKey;
      audio.volume = next.isMuted ? 0 : next.volume;
      if (sourceChanged) {
        resetSample();
        sourceIdRef.current = sourceKey;
        audio.pause();
        if (next.currentSong?.audioUrl) audio.src = next.currentSong.audioUrl;
        else { audio.removeAttribute('src'); audio.load(); }
      }
      // Store-driven seeks include the lyrics buttons and previous-track reset.
      if (!sourceChanged && next.currentTime !== previous?.currentTime && Math.abs(audio.currentTime - next.currentTime) > 1.1) {
        audio.currentTime = next.currentTime;
      }
      if (sourceChanged || next.isPlaying !== previous?.isPlaying || (next.currentTime === 0 && previous?.currentTime > 0 && next.isPlaying)) {
        if (next.isPlaying && next.currentSong?.audioUrl) play();
        else audio.pause();
      }
    };
    sync(state());
    const unsubscribe = usePlayerStore.subscribe(sync);
    return () => {
      unsubscribe();
      window.clearInterval(playbackTimer);
      for (const event of ['seeking', 'waiting', 'pause', 'ended', 'emptied']) audio.removeEventListener(event, resetSample);
      audio.removeEventListener('timeupdate', timeupdate);
      audio.removeEventListener('loadedmetadata', metadata);
      audio.removeEventListener('ended', ended);
      audio.removeEventListener('error', failPlayback);
      audio.removeEventListener('playing', recordPlayback);
      audio.pause();
      audio.removeAttribute('src');
      audio.load();
      audioRef.current = null;
      sourceIdRef.current = null;
    };
  }, [seek]);

  return { audioRef, seek };
}
