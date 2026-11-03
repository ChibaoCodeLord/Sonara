import React from 'react';
import { Volume2, Volume1, VolumeX } from 'lucide-react';
import { usePlayerStore } from '../../store/usePlayerStore';

export function VolumeControl({ className = "" }) {
  const volume = usePlayerStore((s) => s.volume);
  const isMuted = usePlayerStore((s) => s.isMuted);
  const setVolume = usePlayerStore((s) => s.setVolume);
  const toggleMute = usePlayerStore((s) => s.toggleMute);

  const displayVolume = isMuted ? 0 : volume;

  const renderIcon = () => {
    if (isMuted || displayVolume === 0) {
      return <VolumeX className="w-4 h-4 text-sonara-muted" />;
    }
    if (displayVolume < 0.5) {
      return <Volume1 className="w-4 h-4 text-sonara-secondary" />;
    }
    return <Volume2 className="w-4 h-4 text-sonara-text" />;
  };

  return (
    <div className={`flex items-center gap-2 group ${className}`}>
      <button
        onClick={toggleMute}
        className="p-1 rounded-lg text-sonara-muted hover:text-sonara-text transition-colors"
        title={isMuted ? 'Bật âm thanh' : 'Tắt tiếng'}
      >
        {renderIcon()}
      </button>

      <div
        className="volume-slider relative w-20 md:w-24 h-3 flex items-center cursor-pointer select-none"
      >
        <input type="range" aria-label="Âm lượng" min={0} max={1} step={0.01} value={displayVolume} onChange={e => setVolume(Number(e.target.value))} className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10" />
        <div className="w-full h-1 group-hover:h-1.5 bg-sonara-elevated rounded-full overflow-hidden transition-all duration-150">
          <div
            className="h-full bg-sonara-secondary group-hover:bg-rose-500 rounded-full transition-colors"
            style={{ width: `${displayVolume * 100}%` }}
          />
        </div>
      </div>
    </div>
  );
}
