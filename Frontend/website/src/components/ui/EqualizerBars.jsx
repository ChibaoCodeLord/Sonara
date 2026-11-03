import React from 'react';

export function EqualizerBars({ isPlaying = true, className = "" }) {
  return (
    <div className={`flex items-end gap-[3px] h-4 w-4 ${className}`} aria-label="Đang phát nhạc">
      <span
        className={`w-[3px] bg-rose-500 rounded-full ${
          isPlaying ? 'animate-wave-1' : 'h-1'
        }`}
      />
      <span
        className={`w-[3px] bg-rose-500 rounded-full ${
          isPlaying ? 'animate-wave-2' : 'h-2'
        }`}
      />
      <span
        className={`w-[3px] bg-rose-500 rounded-full ${
          isPlaying ? 'animate-wave-3' : 'h-3'
        }`}
      />
      <span
        className={`w-[3px] bg-rose-500 rounded-full ${
          isPlaying ? 'animate-wave-4' : 'h-1.5'
        }`}
      />
    </div>
  );
}
