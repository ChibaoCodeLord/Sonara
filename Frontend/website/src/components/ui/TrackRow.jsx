import React from 'react';
import { Play, Pause, Heart, Plus, MoreHorizontal, Info } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { playableTrack, playbackLabel } from '../../utils/catalogEntities';
import { useAppStore } from '../../store/useAppStore';
import { usePlayerStore } from '../../store/usePlayerStore';
import { EqualizerBars } from './EqualizerBars';
import { Badge } from './Badge';
import { formatTime } from '../../utils/formatters';

export function TrackRow({
  song,
  index,
  rank,
  rankChange,
  rankChangeType,
  showRank = false,
  showAlbum = true,
  onPlay,
  playlistId,
  className = ""
}) {
  const currentSong = usePlayerStore((s) => s.currentSong);
  const isPlaying = usePlayerStore((s) => s.isPlaying);
  const likedSongIds = usePlayerStore((s) => s.likedSongIds);
  const toggleFavorite = usePlayerStore((s) => s.toggleFavorite);
  const addToQueue = usePlayerStore((s) => s.addToQueue);
  const togglePlay = usePlayerStore((s) => s.togglePlay);
  const openDialog = useAppStore(s => s.openDialog);
  const navigate = useNavigate();
  const canPlay = playableTrack(song);

  const isCurrentActive = currentSong?.id === song?.id;
  const isFavorite = likedSongIds.includes(song?.id);
  const external = song?.embedCheck?.status === 'blocked';

  const handlePlayClick = (e) => {
    e.stopPropagation();
    if (!canPlay) { navigate(`/track/${song.id}`); return; }
    if (external) { window.open(song.sourceUrl, '_blank', 'noopener,noreferrer'); return; }
    if (isCurrentActive) togglePlay();
    else if (onPlay) onPlay(song);
  };

  const handleHeartClick = (e) => {
    e.stopPropagation();
    toggleFavorite(song.id);
  };

  const handleAddQueue = (e) => {
    e.stopPropagation();
    addToQueue(song);
  };

  return (
    <div
      onClick={handlePlayClick}
      className={`track-row group flex min-w-0 items-center gap-3.5 px-3 py-2.5 rounded-xl hover:bg-sonara-cardHover/70 transition-all duration-200 cursor-pointer ${
        isCurrentActive ? 'bg-rose-950/20 border border-rose-900/30' : 'border border-transparent'
      } ${className}`}
    >
      {/* Rank or Index column */}
      {showRank ? (
        <div className="flex flex-col items-center justify-center w-8 shrink-0">
          <span
            className={`text-base font-extrabold ${
              rank === '01' ? 'text-sonara-link' : 'text-sonara-muted group-hover:text-sonara-text'
            }`}
          >
            {rank || (index !== undefined ? (index + 1).toString().padStart(2, '0') : '')}
          </span>
          {rankChange && (
            <span
              className={`text-[10px] font-medium leading-none mt-0.5 ${
                rankChangeType === 'up'
                  ? 'text-sonara-success'
                  : rankChangeType === 'down'
                  ? 'text-sonara-link'
                  : 'text-sonara-subtext'
              }`}
            >
              {rankChange}
            </span>
          )}
        </div>
      ) : (
        <div className="track-index w-6 text-center text-xs text-sonara-muted group-hover:hidden group-focus-within:hidden shrink-0">
          {isCurrentActive && isPlaying ? (
            <EqualizerBars isPlaying={isPlaying} />
          ) : (
            (index !== undefined ? index + 1 : '')
          )}
        </div>
      )}

      {/* Play button replacement for index on hover */}
      {!showRank && (
        <button
          aria-label={!canPlay ? `Thông tin ${song.title}` : external ? `Xem ${song.title} trên YouTube` : isCurrentActive && isPlaying ? `Tạm dừng ${song.title}` : `Phát ${song.title}`}
          onClick={handlePlayClick}
          className="track-play hidden group-hover:flex group-focus-within:flex w-6 h-6 items-center justify-center text-sonara-text hover:text-sonara-link shrink-0"
        >
          {!canPlay ? <Info className="w-4 h-4" /> : isCurrentActive && isPlaying ? (
            <Pause className="w-4 h-4 fill-current" />
          ) : (
            <Play className="w-4 h-4 fill-current" />
          )}
        </button>
      )}

      {/* Thumbnail */}
      <div className="relative w-11 h-11 rounded-lg overflow-hidden shrink-0 bg-sonara-elevated">
        <img
          src={song.coverUrl || '/images/catalog-placeholder.svg'}
          alt={song.title}
          className="w-full h-full object-cover"
        />
        {/* Hover play icon over artwork if ranking mode */}
        {showRank && (
          <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
            {isCurrentActive && isPlaying ? (
              <Pause className="w-4 h-4 text-white fill-current" />
            ) : (
              <Play className="w-4 h-4 text-white fill-current ml-0.5" />
            )}
          </div>
        )}
      </div>

      {/* Title & Artist */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <button
            onClick={handlePlayClick}
            className={`min-w-0 text-left font-semibold text-sm truncate ${
              isCurrentActive ? 'text-sonara-link' : 'text-sonara-text group-hover:text-sonara-text'
            }`}
          >
            {song.title}
          </button>
          {song.isLossless && (
            <Badge variant="lossless" className="track-badges shrink-0 scale-90 origin-left">
              LOSSLESS
            </Badge>
          )}
          {song.isExplicit && (
            <span className="px-1.5 py-0.2 rounded text-[9px] font-bold bg-sonara-elevated text-sonara-muted border border-slate-700">
              E
            </span>
          )}
          {song.matchPercentage && (
            <Badge variant="match" className="track-badges shrink-0 scale-90 origin-left">
              {song.matchPercentage} Khớp
            </Badge>
          )}
        </div>
        <p className="text-xs text-sonara-muted truncate mt-0.5">
          {song.artist}
          {!canPlay && <span> · {playbackLabel(song)}</span>}
        </p>
      </div>

      {/* Album (hidden on smaller screens) */}
      {showAlbum && song.album && (
        <div className="hidden xl:block w-36 text-xs text-sonara-muted truncate">
          {song.album}
        </div>
      )}

      {/* Plays or Context Hint */}
      {song.plays && (
        <div className="hidden xl:block text-xs text-sonara-muted text-right w-24">
          {song.plays}
        </div>
      )}

      {/* Actions */}
      <div className="track-actions flex items-center gap-2 shrink-0">
        <button aria-label={`Tùy chọn ${song.title}`} title="Tùy chọn bài hát" onClick={e => { e.stopPropagation(); openDialog('song-menu', { songId: song.id, playlistId }); }} className="ui-icon-button w-7 h-7"><MoreHorizontal size={16} /></button>
        <button
          onClick={handleHeartClick}
          className={`p-1.5 rounded-lg transition-colors ${
            isFavorite
              ? 'text-sonara-link hover:text-sonara-link'
              : 'text-sonara-muted opacity-0 group-hover:opacity-100 group-focus-within:opacity-100 hover:text-sonara-text'
          }`}
          title={isFavorite ? 'Bỏ thích' : 'Yêu thích'}
        >
          <Heart className={`w-4 h-4 ${isFavorite ? 'fill-current' : ''}`} />
        </button>

        <button
          onClick={handleAddQueue}
          className="p-1.5 text-sonara-muted opacity-0 group-hover:opacity-100 group-focus-within:opacity-100 hover:text-sonara-text rounded-lg transition-colors"
          title="Thêm vào hàng đợi"
          disabled={!canPlay}
        >
          <Plus className="w-4 h-4" />
        </button>

        <span className="track-duration text-xs text-sonara-muted w-11 text-right">
          {song.provider === 'youtube' ? external ? 'Xem ↗' : 'YouTube' : song.durationSeconds ? formatTime(song.durationSeconds) : '—'}
        </span>
      </div>
    </div>
  );
}
