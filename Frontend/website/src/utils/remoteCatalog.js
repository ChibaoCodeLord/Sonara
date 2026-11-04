export function mergeCatalog(remote, local) {
  const ids = new Set();
  return [...remote, ...local].filter(track => {
    if (ids.has(track.id)) return false;
    ids.add(track.id); return true;
  });
}

export async function fetchActiveCatalog(fetcher = fetch, base = '/api/v1/catalog') {
  for (let attempt=0; attempt<3; attempt++) {
    try { return await fetchCatalogSnapshot(fetcher,base); }
    catch(error) { if(error.code!=='CATALOG_CHANGED'||attempt===2)throw error; }
  }
}

async function fetchCatalogSnapshot(fetcher, base) {
  const tracks = []; const seen = new Set(); let dataset, snapshot;
  for (let page = 1; page <= 1000; page++) {
    const response = await fetcher(`${base.replace(/\/$/, '')}?limit=100&page=${page}${snapshot?'&snapshot='+encodeURIComponent(snapshot):''}`, { signal: AbortSignal.timeout(20000), cache: 'no-store' });
    if(response.status===409)throw Object.assign(new Error('Catalog vừa cập nhật. Hãy tải lại.'),{code:'CATALOG_CHANGED'});
    if (!response.ok) throw new Error('Chưa tải được catalog từ máy chủ.');
    const { data } = await response.json();
    if (!data?.dataset || !Array.isArray(data.tracks) || !Number.isInteger(data.pagination?.totalPages)) throw new Error('Catalog không hợp lệ.');
    if (dataset && dataset !== data.dataset) throw Object.assign(new Error('Catalog vừa thay đổi. Hãy tải lại.'),{code:'CATALOG_CHANGED'});
    dataset = data.dataset;
    if(data.snapshot)snapshot=data.snapshot;
    for (const track of data.tracks) {
      if (!track.id || !track.title || !['full','preview','metadata'].includes(track.playbackKind)) throw new Error('Thông tin bài hát không hợp lệ.');
      if (seen.has(track.id)) throw new Error('Catalog trùng ID bài hát.');
      seen.add(track.id); tracks.push(track);
    }
    if (page >= data.pagination.totalPages) return { tracks, dataset };
  }
  throw new Error('Catalog vượt giới hạn tải.');
}

// Deduplicate discovery cards only; keep original IDs in the full catalog for saved playlists.
export function uniqueYouTubeTracks(tracks) {
  const seen = new Set();
  return tracks.filter(track => {
    if (!['youtube', 'youtube-audio', 'audio', 'audius', 'archive'].includes(track.provider)) return false;
    const key = track.youtubeId || track.id;
    if (seen.has(key)) return false;
    seen.add(key); return true;
  });
}

export async function fetchMusicBrainzCatalog(fetcher = fetch, base = '/api/v1/catalog') {
  const tracks = [];
  for (let page = 1; page <= 10; page++) {
    const response = await fetcher(`${base.replace(/\/$/, '')}/musicbrainz?matched=true&limit=100&page=${page}`, { signal: AbortSignal.timeout(15000) });
    if (!response.ok) throw new Error('Chưa tải được tuyển tập mới.');
    const json = await response.json();
    const data = json.data;
    if (!Array.isArray(data?.tracks) || !Number.isInteger(data.pagination?.totalPages)) throw new Error('Dữ liệu tuyển tập chưa hợp lệ.');
    if (data.tracks.some(track => !['youtube', 'audio'].includes(track.provider) || (track.provider === 'youtube' && !/^[\w-]{11}$/.test(track.youtubeId || '')) || (track.provider === 'audio' && !track.audioUrl) || !track.id || !track.title)) throw new Error('Nội dung trong tuyển tập chưa hợp lệ.');
    tracks.push(...data.tracks);
    if (page >= data.pagination.totalPages) return tracks;
  }
  throw new Error('Tuyển tập vượt giới hạn tải.');
}

export async function fetchAudiusCatalog(fetcher = fetch, base = '/api/v1/catalog') {
  const tracks = [];
  for (let page = 1; page <= 1000; page++) {
    const response = await fetcher(`${base.replace(/\/$/, '')}/audius?limit=100&page=${page}`, { signal: AbortSignal.timeout(15000) });
    if (!response.ok) throw new Error('Chưa tải được nhạc Audius.');
    const { data } = await response.json();
    if (!Array.isArray(data?.tracks) || !Number.isInteger(data.pagination?.totalPages) || data.tracks.some(track => track.provider !== 'audius' || !track.audioUrl || !track.id)) throw new Error('Dữ liệu Audius chưa hợp lệ.');
    tracks.push(...data.tracks);
    if (page >= data.pagination.totalPages) return tracks;
  }
  throw new Error('Danh mục Audius vượt giới hạn tải.');
}

export async function fetchArchiveCatalog(fetcher = fetch, base = '/api/v1/catalog') {
  const tracks = [];
  for (let page = 1; page <= 1000; page++) {
    const response = await fetcher(`${base.replace(/\/$/, '')}/archive?limit=100&page=${page}`, { signal: AbortSignal.timeout(15000) });
    if (!response.ok) throw new Error('Chưa tải được nhạc Internet Archive.');
    const { data } = await response.json();
    if (!Array.isArray(data?.tracks) || !Number.isInteger(data.pagination?.totalPages) || data.tracks.some(track => track.provider !== 'archive' || !track.audioUrl || !track.licenseUrl || !track.id)) throw new Error('Dữ liệu Internet Archive chưa hợp lệ.');
    tracks.push(...data.tracks);
    if (page >= data.pagination.totalPages) return tracks;
  }
  throw new Error('Danh mục Internet Archive vượt giới hạn tải.');
}
