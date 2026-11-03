import React from 'react';
import {
  ChevronDown,
  Heart,
  Shuffle,
  SkipBack,
  Play,
  Pause,
  SkipForward,
  Repeat,
  Radio,
  Headphones,
  Maximize2
} from 'lucide-react';
import { usePlayerStore } from '../../store/usePlayerStore';
import { Scrubber } from './Scrubber';

import { useOverlayFocus } from '../../hooks/useOverlayFocus';
import { useAppStore } from '../../store/useAppStore';
import { Link } from 'react-router-dom';

export function FullscreenPlayer({ onSeek }) {
  const isFullscreen = usePlayerStore((s) => s.isFullscreenPlayer);
  const toggleFullscreen = usePlayerStore((s) => s.toggleFullscreenPlayer);
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
  const isSpatial3D = usePlayerStore((s) => s.isSpatial3D);
  const toggleSpatial3D = usePlayerStore((s) => s.toggleSpatial3D);
  const toggleLyrics = usePlayerStore((s) => s.toggleLyrics);
  const panelRef = useOverlayFocus(isFullscreen, () => toggleFullscreen(false));
  const openDialog = useAppStore(s => s.openDialog);

  if (!isFullscreen || !currentSong) return null;

  const isFavorite = likedSongIds.includes(currentSong?.id);

  return (
    <div ref={panelRef} role="dialog" aria-modal="true" aria-label="Trình phát toàn màn hình" tabIndex={-1} className="fixed inset-0 z-50 bg-gradient-to-b from-sonara-elevated via-sonara-base to-sonara-base flex flex-col gap-4 p-4 sm:p-6 md:p-8 overflow-y-auto animate-in fade-in duration-300">
      {/* Top Header */}
      <div className="flex items-center justify-between w-full max-w-4xl mx-auto shrink-0">
        <button
          onClick={() => toggleFullscreen(false)}
          className="p-2.5 rounded-full bg-sonara-overlay/5 hover:bg-sonara-overlay/10 text-sonara-secondary hover:text-sonara-text transition-colors"
          title="Thu nhỏ"
        >
          <ChevronDown className="w-6 h-6" />
        </button>

        <div className="text-center">
          <span className="text-[11px] font-bold tracking-widest uppercase text-sonara-muted block">
            PHÁT TỪ GỢI Ý
          </span>
          <span className="text-xs font-semibold text-sonara-link flex items-center justify-center gap-1.5 mt-0.5">
            <Radio className="w-3.5 h-3.5" />
            {currentSong?.contextHint || 'AI Hum Match (98%)'}
          </span>
        </div>

        <button
          onClick={() => {
            toggleFullscreen(false);
            toggleLyrics(true);
          }}
          className="p-2.5 rounded-full bg-sonara-overlay/5 hover:bg-sonara-overlay/10 text-sonara-secondary hover:text-sonara-text transition-colors"
          title="Xem lời bài hát"
        >
          <Maximize2 className="w-5 h-5" />
        </button>
      </div>

      {/* Center Artwork & Info */}
      <div className="flex flex-col shrink-0 items-center justify-center my-auto py-2 max-w-md mx-auto w-full">
        {/* Large Artwork */}
        <div className="fullscreen-artwork relative aspect-square rounded-3xl overflow-hidden shadow-2xl shadow-rose-950/40 border border-sonara-overlay/10 group mb-5">
          <img
            src={currentSong?.coverUrl || '/images/catalog-placeholder.svg'}
            alt={currentSong?.title}
            className="w-full h-full object-cover"
          />

          {/* Lossless 24-bit Badge */}
          <div className="theme-inverse absolute top-4 left-4 px-3 py-1 rounded-full bg-black/60 backdrop-blur-md border border-sonara-overlay/10 text-[11px] font-bold text-sonara-link uppercase tracking-wider flex items-center gap-1.5">
            <span className="w-1.5 h-1.5 rounded-full bg-rose-500 animate-pulse" />
            LOSSLESS • 24-BIT
          </div>
        </div>

        {/* Song Info Bar */}
        <div className="flex items-center justify-between w-full mb-6 px-2">
          <div className="min-w-0 pr-4">
            <div className="flex items-center gap-2">
              <h2 className="text-2xl font-bold text-sonara-text truncate">
                {currentSong?.title}
              </h2>
              {currentSong?.isExplicit && (
                <span className="px-1.5 py-0.2 rounded text-[10px] font-bold bg-sonara-elevated text-sonara-muted border border-slate-700">
                  E
                </span>
              )}
            </div>
            <p className="text-base text-sonara-muted truncate mt-1">
              {currentSong?.artist}
            </p>
          </div>

          <div className="flex items-center gap-3 shrink-0">
            <button
              aria-label={isFavorite ? 'Bỏ thích' : 'Yêu thích'}
              onClick={() => toggleFavorite(currentSong?.id)}
              className="p-2 text-sonara-muted hover:text-sonara-link transition-colors"
            >
              <Heart className={`w-6 h-6 ${isFavorite ? 'fill-rose-500 text-sonara-link' : ''}`} />
            </button>
          </div>
        </div>

        {/* Scrubber Bar */}
        <div className="w-full mb-6">
          <Scrubber onSeek={onSeek} />
        </div>

        {/* Controls */}
        <div className="flex items-center justify-between w-full max-w-xs mb-8">
          <button
            onClick={toggleShuffle}
            className={`p-2 transition-colors ${
              isShuffle ? 'text-sonara-link' : 'text-sonara-muted hover:text-sonara-text'
            }`}
            title="Xáo trộn"
          >
            <Shuffle className="w-5 h-5" />
          </button>

          <button
            onClick={prevSong}
            className="p-2 text-sonara-text hover:text-sonara-text transition-transform active:scale-95"
            title="Bài trước"
          >
            <SkipBack className="w-7 h-7 fill-current" />
          </button>

          <button
            onClick={togglePlay}
            className="w-16 h-16 rounded-full bg-rose-600 hover:bg-rose-500 text-white flex items-center justify-center shadow-xl shadow-rose-900/50 transition-transform hover:scale-105 active:scale-95"
            title={isPlaying ? 'Tạm dừng' : 'Phát'}
          >
            {isPlaying ? (
              <Pause className="w-8 h-8 fill-current" />
            ) : (
              <Play className="w-8 h-8 fill-current ml-1" />
            )}
          </button>

          <button
            onClick={nextSong}
            className="p-2 text-sonara-text hover:text-sonara-text transition-transform active:scale-95"
            title="Bài tiếp theo"
          >
            <SkipForward className="w-7 h-7 fill-current" />
          </button>

          <button
            onClick={cycleRepeat}
            className={`p-2 transition-colors ${
              repeatMode !== 'off' ? 'text-sonara-link' : 'text-sonara-muted hover:text-sonara-text'
            }`}
            title={`Lặp lại: ${repeatMode}`}
          >
            <Repeat className="w-5 h-5" />
          </button>
        </div>

        {/* Acoustic Output Chips */}
        <div className="flex flex-wrap justify-center items-center gap-3">
          <button
            onClick={toggleSpatial3D}
            className={`px-4 py-2 rounded-full text-xs font-semibold flex items-center gap-2 border transition-all ${
              isSpatial3D
                ? 'bg-rose-600/20 text-sonara-link border-rose-500/40 shadow-sm'
                : 'bg-sonara-overlay/5 text-sonara-muted border-sonara-overlay/10'
            }`}
          >
            <span className={`w-2 h-2 rounded-full ${isSpatial3D ? 'bg-rose-500 animate-ping' : 'bg-sonara-trackHover'}`} />
            Sonara Spatial 3D
          </button>

          <button onClick={() => openDialog('devices')} className="px-4 py-2 rounded-full text-xs font-semibold flex items-center gap-2 bg-sonara-overlay/5 text-sonara-muted border border-sonara-overlay/10">
            <Headphones className="w-3.5 h-3.5 text-sonara-muted" />
            Trình duyệt này
          </button>
        </div>
      </div>

      <Link to={`/track/${currentSong?.id}`} onClick={() => toggleFullscreen(false)} className="ui-text-link mx-auto">Xem thông tin bản thu và người thực hiện</Link>
      {/* Synced Lyrics Preview Banner */}
      <div
        onClick={() => {
          toggleFullscreen(false);
          toggleLyrics(true);
        }}
        className="shrink-0 w-full max-w-2xl mx-auto p-4 rounded-2xl bg-sonara-overlay/5 hover:bg-sonara-overlay/10 border border-sonara-overlay/10 cursor-pointer transition-all backdrop-blur-md"
      >
        <div className="flex items-center justify-between mb-2">
          <span className="text-xs font-bold text-sonara-link uppercase tracking-wider flex items-center gap-1.5">
            Lời bài hát đồng bộ
          </span>
          <span className="text-xs text-sonara-muted">Nhấn để mở toàn bộ ›</span>
        </div>
            <p className="fullscreen-lyric-preview text-sm font-semibold text-sonara-text truncate">
          "Hãy hứa với anh rằng em sẽ tìm được một bầu trời mới thật bình yên..."
        </p>
      </div>
    </div>
  );
}
