import React from 'react';
import { useYouTubeAudio } from '../../hooks/useYouTubeAudio';
import { usePlayerStore } from '../../store/usePlayerStore';
export function AudioPreparation() {
  const { status, retry } = useYouTubeAudio();
  if (!status) return null;
  return <div className="fixed left-3 right-3 bottom-28 sm:left-auto sm:max-w-sm z-40 rounded-xl border border-sonara-border bg-sonara-surface p-3 text-sm shadow-xl"><p role="status">{status.error || `Đang chuẩn bị MP3… ${status.progress}%`}</p><div className="flex gap-4 mt-2">{status.error && <button className="ui-text-link" onClick={retry}>Thử lại</button>}<button className="ui-text-link" onClick={() => usePlayerStore.getState().pause()}>Tạm dừng</button></div></div>;
}
