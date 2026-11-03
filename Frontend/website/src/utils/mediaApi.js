export async function mediaRequest(path, options = {}) {
  let response;
  try { response = await fetch(`/media-api${path}`, { ...options, headers: { 'Content-Type': 'application/json', 'X-Sonara-Client': 'website', ...options.headers }, signal: options.signal ? AbortSignal.any([options.signal, AbortSignal.timeout(40000)]) : AbortSignal.timeout(40000) }); }
  catch (error) { if (error.name === 'AbortError') throw error; throw new Error('Không kết nối được dịch vụ MP3. Hãy chạy npm run media trong thư mục Backend.'); }
  if (response.status === 204) return null;
  let body;
  try { body = await response.json(); } catch { throw new Error('Dịch vụ MP3 chưa sẵn sàng. Hãy chạy npm run media trong thư mục Backend.'); }
  if (!response.ok) throw Object.assign(new Error(body.error || 'Không thể xử lý yêu cầu.'), { status: response.status });
  return body;
}
export function validYoutubeLink(value) {
  try {
    const url = new URL(value), hosts = ['youtube.com', 'www.youtube.com', 'm.youtube.com', 'music.youtube.com', 'youtu.be'];
    if (url.protocol !== 'https:' || url.port || url.username || url.password || !hosts.includes(url.hostname)) return false;
    const id = url.hostname === 'youtu.be' ? url.pathname.slice(1) : url.pathname === '/watch' ? url.searchParams.get('v') : /^\/(shorts|live|embed)\//.test(url.pathname) ? url.pathname.split('/')[2] : '';
    return /^[\w-]{11}$/.test(id || '');
  } catch { return false; }
}
