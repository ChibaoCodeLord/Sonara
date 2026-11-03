import React, { useEffect, useRef } from 'react';
import { X, Mic2, Maximize2, Sparkles } from 'lucide-react';
import { usePlayerStore } from '../../store/usePlayerStore';
import { Badge } from '../ui/Badge';
import { useOverlayFocus } from '../../hooks/useOverlayFocus';

export function LyricsDrawer() {
  const isLyricsOpen = usePlayerStore((s) => s.isLyricsOpen);
  const toggleLyrics = usePlayerStore((s) => s.toggleLyrics);
  const currentSong = usePlayerStore((s) => s.currentSong);
  const currentTime = usePlayerStore((s) => s.currentTime);
  const seekTo = usePlayerStore((s) => s.seekTo);
  const isKaraokeMode = usePlayerStore((s) => s.isKaraokeMode);
  const toggleKaraokeMode = usePlayerStore((s) => s.toggleKaraokeMode);
  const toggleFullscreenPlayer = usePlayerStore((s) => s.toggleFullscreenPlayer);
  const panelRef = useOverlayFocus(isLyricsOpen, () => toggleLyrics(false));

  const activeLineRef = useRef(null);
  const lyricsList = currentSong?.lyrics || [];

  // Determine current active lyric index based on currentTime
  let activeIndex = -1;
  for (let i = lyricsList.length - 1; i >= 0; i--) {
    if (currentTime >= lyricsList[i].timeSeconds) {
      activeIndex = i;
      break;
    }
  }

  // Auto-scroll to active lyric smoothly
  useEffect(() => {
    if (activeLineRef.current) {
      activeLineRef.current.scrollIntoView({
        behavior: 'smooth',
        block: 'center'
      });
    }
  }, [activeIndex, isLyricsOpen]);

  if (!isLyricsOpen) return null;

  return (
    <div ref={panelRef} role="dialog" aria-label="Lời bài hát" tabIndex={-1} className="player-drawer fixed top-0 right-0 w-full sm:w-[480px] lg:w-[540px] z-40 bg-sonara-surface/95 backdrop-blur-2xl border-l border-sonara-border/80 flex flex-col shadow-2xl animate-in slide-in-from-right duration-300">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-3 px-4 py-4 border-b border-sonara-border/60 shrink-0">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-xl bg-rose-500/10 text-sonara-link">
            <Mic2 className="w-5 h-5" />
          </div>
          <div>
            <h3 className="font-bold text-base text-sonara-text flex items-center gap-2">
              Lời bài hát đồng bộ
              <Badge variant="lossless">Hi-Res</Badge>
            </h3>
            <p className="text-xs text-sonara-muted mt-0.5 truncate max-w-[240px]">
              {currentSong?.title} • {currentSong?.artist}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {/* Karaoke Mode Toggle */}
          <button
            onClick={toggleKaraokeMode}
            className={`px-3 py-1.5 rounded-full text-xs font-semibold flex items-center gap-1.5 transition-all border ${
              isKaraokeMode
                ? 'bg-rose-600 text-white border-rose-500 shadow-md shadow-rose-900/40'
                : 'bg-sonara-overlay/5 text-sonara-secondary border-sonara-overlay/10 hover:bg-sonara-overlay/10'
            }`}
            title="Tách giọng ca sĩ để hát Karaoke"
          >
            <Sparkles className="w-3.5 h-3.5" />
            Karaoke
          </button>

          {/* Fullscreen Button */}
          <button
            onClick={() => {
              toggleLyrics(false);
              toggleFullscreenPlayer(true);
            }}
            className="p-2 text-sonara-muted hover:text-sonara-text rounded-lg hover:bg-sonara-overlay/5 transition-colors"
            title="Mở toàn màn hình"
          >
            <Maximize2 className="w-4 h-4" />
          </button>

          {/* Close Button */}
          <button
            aria-label="Đóng lời bài hát"
            onClick={() => toggleLyrics(false)}
            className="p-2 text-sonara-muted hover:text-sonara-text rounded-lg hover:bg-sonara-overlay/5 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Lyrics Content Area */}
      <div className="flex-1 min-h-0 overflow-y-auto px-4 py-6 space-y-6">
        {lyricsList.length > 0 ? (
          lyricsList.map((line, idx) => {
            const isActive = idx === activeIndex;
            return (
              <button
                key={idx}
                ref={isActive ? activeLineRef : null}
                onClick={() => seekTo(line.timeSeconds)}
                className={`block w-full text-left cursor-pointer transition-all duration-300 rounded-xl p-3 select-none ${
                  isActive
                    ? 'text-sonara-text text-xl sm:text-2xl font-bold bg-rose-600/10 border-l-4 border-rose-500 pl-4 scale-[1.02]'
                    : 'text-sonara-muted/60 hover:text-sonara-secondary text-base sm:text-lg font-medium hover:bg-sonara-overlay/5'
                }`}
              >
                {line.text}
              </button>
            );
          })
        ) : (
          <div className="flex flex-col items-center justify-center h-full text-center py-20 text-sonara-subtext">
            <Mic2 className="w-12 h-12 mb-3 stroke-1" />
            <p className="text-sm">Chưa có lời đồng bộ cho bài hát này</p>
          </div>
        )}
      </div>

      {/* Footer Info */}
      <div className="p-4 bg-sonara-base/60 border-t border-sonara-border/40 text-center shrink-0">
        <p className="text-[11px] text-sonara-muted flex items-center justify-center gap-1.5">
          <Sparkles className="w-3.5 h-3.5 text-sonara-link" />
          Nhấn vào bất kỳ dòng nào để nhảy ngay đến đoạn đó
        </p>
      </div>
    </div>
  );
}
