import React from 'react';
import { usePlayerStore } from '../../store/usePlayerStore';
import { Sparkles } from 'lucide-react';

export function Toast() {
  const toastMessage = usePlayerStore((s) => s.toastMessage);

  if (!toastMessage) return null;

  return (
    <div role="status" className="fixed top-4 right-4 max-w-[calc(100vw-2rem)] z-[70] flex items-center gap-3 px-4 py-3 rounded-xl bg-sonara-field/95 border border-rose-500/30 text-sonara-text shadow-2xl backdrop-blur-xl animate-in fade-in slide-in-from-top-4 duration-200">
      <div className="p-1.5 rounded-lg bg-rose-500/20 text-sonara-link">
        <Sparkles className="w-4 h-4" />
      </div>
      <p className="text-sm font-medium pr-2">{toastMessage}</p>
    </div>
  );
}
