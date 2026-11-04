import React from 'react';

export function VisualizerCanvas({ frequencies = [], isRecording = true }) {
  return (
    <div className="flex items-center justify-center gap-1.5 sm:gap-2 h-20 w-full max-w-sm px-4">
      {frequencies.map((heightPercent, index) => {
        // Calculate gradient intensity based on distance from center
        const centerOffset = Math.abs(index - Math.floor(frequencies.length / 2));
        const isCore = centerOffset < 4;

        return (
          <div
            key={index}
            className="flex items-center justify-center h-full w-2"
          >
            <div
              className={`w-1.5 sm:w-2 rounded-full transition-all duration-75 ${
                isRecording
                  ? isCore
                    ? 'bg-gradient-to-t from-rose-700 via-rose-500 to-red-400 shadow-[0_0_8px_rgba(244,63,94,0.6)]'
                    : 'bg-gradient-to-t from-rose-900 via-rose-600 to-rose-400'
                  : 'bg-sonara-track h-2'
              }`}
              style={{
                height: `${Math.max(10, Math.min(100, heightPercent))}%`
              }}
            />
          </div>
        );
      })}
    </div>
  );
}
