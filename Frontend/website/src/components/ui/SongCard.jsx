import React from 'react';
import { Play, Pause } from 'lucide-react';
import { usePlayerStore } from '../../store/usePlayerStore';
import { EqualizerBars } from './EqualizerBars';

export function SongCard({
  item,
  onPlay,
  onClick,
  tag,
  className = ""
}) {
  const currentSong = usePlayerStore((s) => s.currentSong);
  const isPlaying = usePlayerStore((s) => s.isPlaying);
  const togglePlay = usePlayerStore((s) => s.togglePlay);
  const isCurrentActive = currentSong?.id === item?.id || currentSong?.id === item?.songIds?.[0];

  return (
    <div
      onClick={onClick}
      className={`group relative flex flex-col p-3.5 rounded-2xl bg-sonara-card/80 hover:bg-sonara-cardHover border border-sonara-border/60 hover:border-sonara-borderLight transition-all duration-300 hover:shadow-xl hover:shadow-black/50 cursor-pointer ${className}`}
    >
      {/* Artwork container */}
      <div className="relative aspect-square w-full rounded-xl overflow-hidden mb-3 bg-sonara-elevated">
        <img
          src={item.coverUrl || item.imageUrl || '/images/catalog-placeholder.svg'}
          alt={item.title}
          className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
          loading="lazy"
        />

        {/* Tag Pill in top-left */}
        {(tag || item.tag) && (
          <span className="absolute top-2.5 left-2.5 px-2.5 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-wider bg-black/60 text-white backdrop-blur-md border border-sonara-overlay/10">
            {tag || item.tag}
          </span>
        )}

        {/* Equalizer indicator if active */}
        {isCurrentActive && isPlaying && (
          <div className="absolute top-2.5 right-2.5 p-1.5 rounded-md bg-black/70 backdrop-blur-md">
            <EqualizerBars isPlaying={isPlaying} />
          </div>
        )}

        {/* Floating Play Button */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            if (isCurrentActive) togglePlay();
            else if (onPlay) onPlay(item);
          }}
          className={`song-card-play absolute bottom-3 right-3 w-11 h-11 rounded-full bg-rose-600 hover:bg-rose-500 text-white flex items-center justify-center shadow-lg shadow-rose-900/40 transition-all duration-300 transform group-focus-within:opacity-100 group-focus-within:translate-y-0 ${
            isCurrentActive && isPlaying
              ? 'opacity-100 scale-100'
              : 'opacity-0 translate-y-2 group-hover:opacity-100 group-hover:translate-y-0 scale-95 hover:scale-105'
          }`}
          aria-label={isCurrentActive && isPlaying ? `Tạm dừng ${item.title}` : `Phát ${item.title}`}
        >
          {isCurrentActive && isPlaying ? (
            <Pause className="w-5 h-5 fill-current" />
          ) : (
            <Play className="w-5 h-5 fill-current ml-0.5" />
          )}
        </button>
      </div>

      {/* Info */}
      <div className="flex flex-col min-w-0">
        <button onClick={e => { e.stopPropagation(); onClick?.(); }} className="text-left font-semibold text-sm text-sonara-text truncate group-hover:text-sonara-link transition-colors">
          {item.title}
        </button>
        <p className="text-xs text-sonara-muted truncate mt-1">
          {item.subtitle || item.artist || item.description}
        </p>
      </div>
    </div>
  );
}
