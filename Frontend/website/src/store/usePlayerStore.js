import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { browserStorage } from '../utils/browserStorage.js';
import { playableTrack } from '../utils/catalogEntities.js';

const trackDuration = song => ['youtube', 'youtube-audio', 'audio', 'audius', 'archive'].includes(song?.provider) ? song.durationSeconds || 0 : song?.durationSeconds || 235;

export const usePlayerStore = create(persist((set, get) => ({
  // Playback state
  currentSong: null,
  isPlaying: false,
  isVideoPlayerOpen: true,
  currentTime: 0,
  seekRevision: 0,
  duration: 0,
  volume: 0.85,
  isMuted: false,
  isShuffle: false,
  repeatMode: 'all', // 'off' | 'all' | 'one'

  // Special Acoustic / AI Features
  isSpatial3D: true,
  isKaraokeMode: false,

  // Drawers & Modals
  isLyricsOpen: false,
  isQueueOpen: false,
  isFullscreenPlayer: false,
  isHumModalOpen: false,

  // Queue state
  queue: [],
  queueIndex: 0,

  // User Library state
  likedSongIds: [],
  followedArtistIds: [],
  toggleFollow: (artistId) => set(state => ({ followedArtistIds: state.followedArtistIds.includes(artistId) ? state.followedArtistIds.filter(id => id !== artistId) : [...state.followedArtistIds, artistId] })),

  // Toast message
  toastMessage: null,

  // Actions
  setToast: (message) => {
    set({ toastMessage: message });
    setTimeout(() => {
      if (get().toastMessage === message) {
        set({ toastMessage: null });
      }
    }, 3000);
  },

  playSong: (song) => {
    if (!playableTrack(song)) { get().setToast('Bài này chỉ có thông tin hoặc bản nghe thử tại nguồn.'); return; }
    if (song?.embedCheck?.status === 'blocked') { get().setToast('Video này chỉ xem được trên YouTube. Mở video gốc trong trang chi tiết.'); return; }
    const queue = get().queue;
    let index = queue.findIndex(s => s.id === song.id);
    const nextQueue = index === -1 ? [...queue, song] : queue;
    if (index === -1) index = nextQueue.length - 1;
    set({
      currentSong: song,
      isPlaying: true,
      currentTime: 0,
      duration: trackDuration(song),
      isVideoPlayerOpen: true,
      queue: nextQueue,
      queueIndex: index
    });
  },

  togglePlay: () => {
    if (!playableTrack(get().currentSong)) return;
    set((state) => ({ isPlaying: !state.isPlaying, isVideoPlayerOpen: true }));
  },

  pause: () => set({ isPlaying: false }),
  resume: () => { if (playableTrack(get().currentSong)) set({ isPlaying: true, isVideoPlayerOpen: true }); },

  seekTo: (seconds) => {
    if (!Number.isFinite(seconds)) return;
    set(state => ({ currentTime: Math.max(0, Math.min(seconds, state.duration)), seekRevision: state.seekRevision + 1 }));
  },

  setCurrentTime: (time) => set({ currentTime: time }),
  setDuration: (dur) => set({ duration: dur }),

  setVolume: (vol) => {
    set({ volume: Math.max(0, Math.min(1, vol)), isMuted: vol === 0 });
  },

  toggleMute: () => {
    set((state) => ({ isMuted: !state.isMuted }));
  },

  nextSong: ({ automatic = false } = {}) => {
    const { queue, queueIndex, isShuffle, repeatMode } = get();
    if (queue.length === 0) return;

    if (automatic && repeatMode === 'one') {
      set({ currentTime: 0, isPlaying: true });
      return;
    }
    if (automatic && repeatMode === 'off' && queueIndex === queue.length - 1) {
      set({ isPlaying: false });
      return;
    }

    let nextIndex;
    if (isShuffle) {
      nextIndex = Math.floor(Math.random() * queue.length);
    } else {
      nextIndex = (queueIndex + 1) % queue.length;
    }

    const nextTrack = queue[nextIndex];
    set({
      queueIndex: nextIndex,
      currentSong: nextTrack,
      currentTime: 0,
      duration: trackDuration(nextTrack),
      isVideoPlayerOpen: true,
      isPlaying: true
    });
  },

  prevSong: () => {
    const { queue, queueIndex, currentTime } = get();
    if (!queue.length) return;
    if (currentTime > 4) {
      set({ currentTime: 0 });
      return;
    }
    const prevIndex = (queueIndex - 1 + queue.length) % queue.length;
    const prevTrack = queue[prevIndex];
    set({
      queueIndex: prevIndex,
      currentSong: prevTrack,
      currentTime: 0,
      duration: trackDuration(prevTrack),
      isVideoPlayerOpen: true,
      isPlaying: true
    });
  },

  toggleShuffle: () => {
    set((state) => ({ isShuffle: !state.isShuffle }));
  },

  cycleRepeat: () => {
    set((state) => {
      const modes = ['off', 'all', 'one'];
      const currentIndex = modes.indexOf(state.repeatMode);
      const nextMode = modes[(currentIndex + 1) % modes.length];
      return { repeatMode: nextMode };
    });
  },

  toggleSpatial3D: () => {
    set((state) => {
      const next = !state.isSpatial3D;
      get().setToast(next ? 'Đã bật Sonara Spatial 3D Audio' : 'Đã tắt Âm thanh vòm 3D');
      return { isSpatial3D: next };
    });
  },

  toggleKaraokeMode: () => {
    set((state) => {
      const next = !state.isKaraokeMode;
      get().setToast(next ? 'Đã kích hoạt chế độ Karaoke (AI Beat Separation)' : 'Đã tắt chế độ Karaoke');
      return { isKaraokeMode: next };
    });
  },

  toggleLyrics: (open) => {
    set((state) => ({
      isLyricsOpen: typeof open === 'boolean' ? open : !state.isLyricsOpen,
      isQueueOpen: false
    }));
  },

  toggleQueue: (open) => {
    set((state) => ({
      isQueueOpen: typeof open === 'boolean' ? open : !state.isQueueOpen,
      isLyricsOpen: false
    }));
  },

  toggleFullscreenPlayer: (open) => {
    set((state) => ({
      isFullscreenPlayer: typeof open === 'boolean' ? open : !state.isFullscreenPlayer
    }));
  },

  toggleHumModal: (open) => {
    set((state) => ({
      isHumModalOpen: typeof open === 'boolean' ? open : !state.isHumModalOpen
    }));
  },

  toggleFavorite: (songId) => {
    set((state) => {
      const exists = state.likedSongIds.includes(songId);
      const next = exists
        ? state.likedSongIds.filter(id => id !== songId)
        : [...state.likedSongIds, songId];
      get().setToast(exists ? 'Đã xóa bài hát khỏi Thư viện' : 'Đã thêm bài hát vào Bài hát yêu thích');
      return { likedSongIds: next };
    });
  },

  addToQueue: (song) => {
    if (!playableTrack(song)) { get().setToast('Chưa có audio để thêm bài này vào hàng đợi.'); return; }
    if (song?.embedCheck?.status === 'blocked') { get().setToast('Video này không cho phép phát nhúng trong Sonara.'); return; }
    set((state) => {
      get().setToast(`Đã thêm "${song.title}" vào hàng đợi`);
      return { queue: [...state.queue, song] };
    });
  },
  removeQueueItem: index => {
    const { queue, queueIndex } = get();
    if (index === queueIndex || index < 0 || index >= queue.length) return;
    set({ queue: queue.filter((_, i) => i !== index), queueIndex: index < queueIndex ? queueIndex - 1 : queueIndex });
  },
  moveQueueItem: (from, to) => {
    const { queue, queueIndex } = get();
    if (from < 0 || to < 0 || from >= queue.length || to >= queue.length) return;
    const next = [...queue]; const [item] = next.splice(from, 1); next.splice(to, 0, item);
    const currentIndex = from === queueIndex ? to : from < queueIndex && to >= queueIndex ? queueIndex - 1 : from > queueIndex && to <= queueIndex ? queueIndex + 1 : queueIndex;
    set({ queue: next, queueIndex: currentIndex });
  },
  clearQueue: () => set(state => ({ queue: state.currentSong ? [state.currentSong] : [], queueIndex: 0 })),
  forgetSong: id => set(state => {
    const queue = state.queue.filter(item => item.id !== id);
    const before = state.queue.filter((item, index) => index < state.queueIndex && item.id !== id).length;
    const queueIndex = Math.min(before, Math.max(0, queue.length - 1));
    const changed = state.currentSong?.id === id;
    const currentSong = changed ? queue[queueIndex] || null : state.currentSong;
    return { queue, queueIndex, currentSong, ...(changed ? { isPlaying: false, currentTime: 0, duration: currentSong?.durationSeconds || 0 } : {}), likedSongIds: state.likedSongIds.filter(value => value !== id) };
  }),

  setQueue: (songs, startIndex = 0) => {
    if (!songs.length) return;
    startIndex = Math.max(0, Math.min(startIndex, songs.length - 1));
    const allowed = songs.map((song, index) => ({ song, index })).filter(item => playableTrack(item.song) && item.song.embedCheck?.status !== 'blocked');
    if (!allowed.length) { get().setToast('Chưa có audio để phát trong danh sách này.'); return; }
    const selected = allowed.findIndex(item => item.index >= startIndex);
    startIndex = selected < 0 ? 0 : selected;
    songs = allowed.map(item => item.song);
    set({
      queue: songs,
      queueIndex: startIndex,
      currentSong: songs[startIndex],
      currentTime: 0,
      duration: trackDuration(songs[startIndex]),
      isVideoPlayerOpen: true,
      isPlaying: true
    });
  },
  shuffleQueue: (songs) => {
    if (!songs.length) return;
    get().setQueue(songs, Math.floor(Math.random() * songs.length));
    set({ isShuffle: true });
  }
}), { name:'sonara-library-v1', version:2, migrate:() => ({ likedSongIds:[], followedArtistIds:[] }), storage:createJSONStorage(() => browserStorage), partialize:state => ({ likedSongIds:state.likedSongIds, followedArtistIds:state.followedArtistIds }) }));
