import React, { useState, useRef } from 'react';
import { usePlayerStore } from '../../store/usePlayerStore';
import { formatTime } from '../../utils/formatters';

export function Scrubber({ onSeek }) {
  const currentTime = usePlayerStore((s) => s.currentTime);
  const duration = usePlayerStore((s) => s.duration) || 0;
  const seekTo = usePlayerStore((s) => s.seekTo);

  const [isHovering, setIsHovering] = useState(false);
  const [hoverTime, setHoverTime] = useState(0);
  const [hoverPosition, setHoverPosition] = useState(0);
  const barRef = useRef(null);

  const progressPercent = duration > 0 ? Math.min(100, Math.max(0, (currentTime / duration) * 100)) : 0;

  const handleMouseMove = (e) => {
    if (!barRef.current) return;
    const rect = barRef.current.getBoundingClientRect();
    const pos = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
    setHoverPosition(pos * 100);
    setHoverTime(Math.floor(pos * duration));
  };

  return (
    <div className="scrubber flex items-center gap-2.5 w-full max-w-xl min-w-0 group">
      {/* Current Time */}
      <span className="text-[11px] font-medium text-sonara-muted w-9 text-right tabular-nums">
        {formatTime(currentTime)}
      </span>

      {/* Progress Track */}
      <div
        ref={barRef}
        onMouseEnter={() => setIsHovering(true)}
        onMouseLeave={() => setIsHovering(false)}
        onMouseMove={handleMouseMove}
        className="relative flex-1 h-3 flex items-center cursor-pointer select-none"
      >
        <input type="range" aria-label="Vị trí phát" disabled={!duration} aria-valuetext={`${formatTime(currentTime)} / ${formatTime(duration)}`} min={0} max={duration || 1} step={1} value={Math.min(currentTime, duration)} onChange={e => {
          const seconds = Number(e.target.value);
          seekTo(seconds);
          onSeek?.(seconds);
        }} className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10" />
        {/* Background Track */}
        <div className="w-full h-1 group-hover:h-1.5 bg-sonara-elevated rounded-full overflow-hidden transition-all duration-150">
          {/* Active Filled Progress Bar */}
          <div
            className="h-full bg-gradient-to-r from-rose-600 via-rose-500 to-red-400 rounded-full"
            style={{ width: `${progressPercent}%` }}
          />
        </div>

        {/* Hover Scrub Handle Knob */}
        <div
          className="absolute w-3 h-3 bg-white rounded-full shadow-md pointer-events-none opacity-0 group-hover:opacity-100 transition-opacity -ml-1.5"
          style={{ left: `${progressPercent}%` }}
        />

        {/* Floating Time Tooltip on Hover */}
        {isHovering && (
          <div
            className="absolute -top-7 -translate-x-1/2 px-2 py-0.5 rounded bg-sonara-field border border-slate-700 text-[10px] font-medium text-sonara-text pointer-events-none shadow-lg z-20 tabular-nums"
            style={{ left: `${hoverPosition}%` }}
          >
            {formatTime(hoverTime)}
          </div>
        )}
      </div>

      {/* Total Duration */}
      <span className="text-[11px] font-medium text-sonara-muted w-9 tabular-nums">
        {formatTime(duration)}
      </span>
    </div>
  );
}
