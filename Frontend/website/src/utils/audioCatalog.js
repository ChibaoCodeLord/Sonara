export function forAudioPlayback(track, cached) {
  if (track.provider !== 'youtube' && track.provider !== 'youtube-audio') return track;
  const { embedCheck, ...original } = track;
  if (cached?.audioUrl) return { ...original, provider: 'audio', audioUrl: cached.audioUrl, durationSeconds: cached.durationSeconds || track.durationSeconds, mediaJobId: cached.mediaJobId };
  return { ...original, provider: 'youtube-audio', videoEmbedCheck: embedCheck };
}
export async function audioJob(path, options = {}) {
  const response = await fetch(`/api/v1/catalog/audio${path}`, { ...options, headers: { 'Content-Type': 'application/json', 'X-Sonara-Client': 'website' }, signal: options.signal ? AbortSignal.any([options.signal, AbortSignal.timeout(40000)]) : AbortSignal.timeout(40000) });
  let job;
  try { job = await response.json(); } catch { throw new Error('Dịch vụ audio chưa sẵn sàng. Hãy thử lại sau.'); }
  if (!response.ok) throw new Error(job.error || 'Chưa chuẩn bị được audio.');
  return job;
}
