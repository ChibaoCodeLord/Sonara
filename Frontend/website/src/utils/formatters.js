// Sonara Formatting Utilities

export function formatTime(seconds) {
  if (seconds === null || seconds === undefined) return '--:--';
  if (isNaN(seconds) || seconds < 0) return '00:00';
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
}

export function formatRemainingTime(current, total) {
  const rem = Math.max(0, total - current);
  return `-${formatTime(rem)}`;
}

export function formatPlays(num) {
  if (typeof num === 'string') return num;
  if (num >= 1000000) {
    return `${(num / 1000000).toFixed(1)}M`;
  }
  if (num >= 1000) {
    return `${(num / 1000).toFixed(0)}k`;
  }
  return num?.toString() || '0';
}
