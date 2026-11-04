import React from 'react';
import {
  Play,
  Pause,
  SkipBack,
  SkipForward,
  Shuffle,
  Repeat,
  Heart,
  Mic2,
  ListMusic,
  Maximize2,
  Radio,
  Monitor
} from 'lucide-react';
import { usePlayerStore } from '../../store/usePlayerStore';
import { Scrubber } from '../player/Scrubber';
import { VolumeControl } from '../player/VolumeControl';
import { EqualizerBars } from '../ui/EqualizerBars';
import { Badge } from '../ui/Badge';
import { useAppStore } from '../../store/useAppStore';

export function BottomPlayer({ onSeek }) {
  const currentSong = usePlayerStore((s) => s.currentSong);
  const isPlaying = usePlayerStore((s) => s.isPlaying);
  const togglePlay = usePlayerStore((s) => s.togglePlay);
  const nextSong = usePlayerStore((s) => s.nextSong);
  const prevSong = usePlayerStore((s) => s.prevSong);
  const isShuffle = usePlayerStore((s) => s.isShuffle);
  const toggleShuffle = usePlayerStore((s) => s.toggleShuffle);
  const repeatMode = usePlayerStore((s) => s.repeatMode);
  const cycleRepeat = usePlayerStore((s) => s.cycleRepeat);
  const likedSongIds = usePlayerStore((s) => s.likedSongIds);
  const toggleFavorite = usePlayerStore((s) => s.toggleFavorite);
  const isLyricsOpen = usePlayerStore((s) => s.isLyricsOpen);
  const toggleLyrics = usePlayerStore((s) => s.toggleLyrics);
  const isQueueOpen = usePlayerStore((s) => s.isQueueOpen);
  const toggleQueue = usePlayerStore((s) => s.toggleQueue);
  const toggleFullscreen = usePlayerStore((s) => s.toggleFullscreenPlayer);
  const isSpatial3D = usePlayerStore((s) => s.isSpatial3D);
  const toggleSpatial3D = usePlayerStore((s) => s.toggleSpatial3D);
  const openDialog = useAppStore(s => s.openDialog);

  const isFavorite = likedSongIds.includes(currentSong?.id);
  const openPlayer = () => toggleFullscreen(true);

  if (!currentSong) return <footer aria-label="Trình phát nhạc" className="bottom-player px-5 bg-sonara-surface border-t border-sonara-border flex items-center"><p className="ui-muted">Chọn một bản thu có audio trong kho nhạc để bắt đầu nghe.</p></footer>;

  return (
    <footer aria-label="Trình phát nhạc" className="bottom-player px-5 bg-sonara-surface/95 backdrop-blur-xl border-t border-sonara-border/80 items-center z-30 select-none">
      {/* 1. Left Section: Song Info & Artwork */}
      <div className="player-info flex items-center gap-3 min-w-0">
        {/* Artwork with expand button */}
        <button
          aria-label="Mở trình phát toàn màn hình"
          onClick={openPlayer}
          className="player-cover relative w-14 h-14 rounded-xl overflow-hidden shrink-0 group cursor-pointer bg-sonara-elevated shadow-md"
        >
          <img
            src={currentSong?.coverUrl || '/images/catalog-placeholder.svg'}
            alt={currentSong?.title}
            className="w-full h-full object-cover transition-transform group-hover:scale-105"
          />
          <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
            <Maximize2 className="w-5 h-5 text-white" />
          </div>
        </button>

        {/* Title & Artist */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <h4
              onClick={openPlayer}
              className="font-bold text-sm text-sonara-text truncate hover:text-sonara-link cursor-pointer"
            >
              {currentSong?.title}
            </h4>
            {currentSong?.isLossless && (
              <Badge variant="lossless" className="player-quality shrink-0 scale-90 origin-left hidden xl:inline-flex">
                LOSSLESS
              </Badge>
            )}
          </div>
          <div className="flex items-center gap-2 mt-0.5">
            <p className="text-xs text-sonara-muted truncate">
              {currentSong?.artist}
            </p>
            {isPlaying && (
              <EqualizerBars isPlaying={isPlaying} className="scale-75 shrink-0" />
            )}
          </div>
        </div>

        {/* Favorite Heart */}
        <button
          onClick={() => toggleFavorite(currentSong?.id)}
          className={`player-favorite p-2 transition-colors shrink-0 ${
            isFavorite ? 'text-sonara-link' : 'text-sonara-muted hover:text-sonara-text'
          }`}
          title={isFavorite ? 'Bỏ thích' : 'Yêu thích'}
        >
          <Heart className={`w-4 h-4 ${isFavorite ? 'fill-current' : ''}`} />
        </button>
      </div>

      {/* 2. Center Section: Playback Controls & Scrubber */}
      <div className="player-controls flex flex-col items-center justify-center px-2">
        {/* Buttons Row */}
        <div className="player-buttons flex items-center gap-4 mb-1.5">
          <button
            onClick={toggleShuffle}
            className={`player-secondary p-1.5 transition-colors ${
              isShuffle ? 'text-sonara-link' : 'text-sonara-muted hover:text-sonara-text'
            }`}
            title="Xáo trộn bài hát"
          >
            <Shuffle className="w-4 h-4" />
          </button>

          <button
            onClick={prevSong}
            className="p-1.5 text-sonara-secondary hover:text-sonara-text transition-transform active:scale-95"
            title="Bài trước"
          >
            <SkipBack className="w-5 h-5 fill-current" />
          </button>

          <button
            onClick={togglePlay}
            className="w-10 h-10 rounded-full bg-rose-600 hover:bg-rose-500 text-white flex items-center justify-center shadow-lg shadow-rose-900/40 transition-transform hover:scale-105 active:scale-95"
            title={isPlaying ? 'Tạm dừng' : 'Phát'}
          >
            {isPlaying ? (
              <Pause className="w-5 h-5 fill-current" />
            ) : (
              <Play className="w-5 h-5 fill-current ml-0.5" />
            )}
          </button>

          <button
            onClick={nextSong}
            className="p-1.5 text-sonara-secondary hover:text-sonara-text transition-transform active:scale-95"
            title="Bài tiếp theo"
          >
            <SkipForward className="w-5 h-5 fill-current" />
          </button>

          <button
            onClick={cycleRepeat}
            className={`player-secondary p-1.5 transition-colors relative ${
              repeatMode !== 'off' ? 'text-sonara-link' : 'text-sonara-muted hover:text-sonara-text'
            }`}
            title={`Lặp lại: ${repeatMode}`}
          >
            <Repeat className="w-4 h-4" />
            {repeatMode === 'one' && (
              <span className="absolute -top-1 -right-1 text-[9px] font-bold">1</span>
            )}
          </button>
        </div>

        {/* Scrubber bar */}
        <Scrubber onSeek={onSeek} />
      </div>

      {/* 3. Right Section: Extra Audio Controls */}
      <div className="player-extras flex items-center gap-1 xl:gap-2">
        <button className="p-2 text-sonara-muted hover:text-sonara-text" title="Kết nối thiết bị" onClick={() => openDialog('devices')}><Monitor size={16} /></button>
        {/* Spatial 3D Audio Toggle */}
        <button
          onClick={toggleSpatial3D}
          className={`hidden xl:flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold border transition-all ${
            isSpatial3D
              ? 'bg-rose-950/60 text-sonara-link border-rose-800/60'
              : 'bg-sonara-overlay/5 text-sonara-muted border-sonara-overlay/5 hover:text-sonara-text'
          }`}
          title="Bật/Tắt Âm thanh vòm Sonara Spatial 3D"
        >
          <Radio className="w-3.5 h-3.5" />
          3D
        </button>

        {/* Lyrics Toggle Button */}
        <button
          onClick={() => toggleLyrics()}
          className={`p-2 rounded-lg transition-colors ${
            isLyricsOpen
              ? 'text-sonara-link bg-rose-500/10'
              : 'text-sonara-muted hover:text-sonara-text hover:bg-sonara-overlay/5'
          }`}
          title="Lời bài hát đồng bộ"
        >
          <Mic2 className="w-4 h-4" />
        </button>

        {/* Queue Toggle Button */}
        <button
          onClick={() => toggleQueue()}
          className={`p-2 rounded-lg transition-colors ${
            isQueueOpen
              ? 'text-sonara-link bg-rose-500/10'
              : 'text-sonara-muted hover:text-sonara-text hover:bg-sonara-overlay/5'
          }`}
          title="Hàng đợi phát nhạc"
        >
          <ListMusic className="w-4 h-4" />
        </button>

        {/* Volume */}
        <VolumeControl className="hidden lg:flex" />

        {/* Fullscreen Button */}
        <button
          onClick={openPlayer}
          className="p-2 text-sonara-muted hover:text-sonara-text rounded-lg hover:bg-sonara-overlay/5 transition-colors hidden md:block"
          title="Mở toàn màn hình"
        >
          <Maximize2 className="w-4 h-4" />
        </button>
      </div>
    </footer>
  );
}
