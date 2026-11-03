export const sourceLabels = { youtube: 'YouTube Audio', jamendo: 'Jamendo', audius: 'Audius', archive: 'Internet Archive', commons: 'Wikimedia Commons',
  freesound: 'Freesound', itunes: 'iTunes', deezer: 'Deezer', musicbrainz: 'MusicBrainz', spotify: 'Spotify', discogs: 'Discogs' };
export const playableTrack = song => Boolean(song?.audioUrl || ['youtube','youtube-audio'].includes(song?.provider));
export const playbackLabel = song => song?.playbackKind === 'preview' ? 'Có bản nghe thử tại nguồn' : playableTrack(song) ? 'Audio' : 'Chỉ thông tin';

export function deriveCatalogEntities(tracks) {
  const artists = new Map(), albums = new Map();
  for (const song of tracks) {
    for (const a of song.artists || []) {
      if (!artists.has(a.id)) artists.set(a.id, { id: a.id, name: a.name, avatarUrl: a.imageUrl || song.coverUrl,
        coverUrl: a.imageUrl || song.coverUrl, bio: '', topTrackIds: [], source: song.metadataSource, verified: false });
      artists.get(a.id).topTrackIds.push(song.id);
    }
    const a = song.albumInfo;
    if (a) {
      if (!albums.has(a.id)) albums.set(a.id, { id: a.id, title: a.title, artist: song.artist, artistId: song.artists?.[0]?.id,
        coverUrl: a.cover_url || song.coverUrl, year: a.release_date?.slice(0,4) || '', type: a.album_type || 'Album',
        songIds: [], source: song.metadataSource, description: '', color: '#304052' });
      albums.get(a.id).songIds.push(song.id);
      for (const credit of a.artists || []) {
        const id = `artist_${song.metadataSource}_${credit.id}`;
        if (!artists.has(id)) artists.set(id, { id, name:credit.name, avatarUrl:credit.image_url || song.coverUrl,
          coverUrl:credit.image_url || song.coverUrl, bio:'', topTrackIds:[], albumIds:[], source:song.metadataSource, verified:false });
        const entity = artists.get(id);
        if (!entity.albumIds) entity.albumIds=[];
        if (!entity.albumIds.includes(a.id)) entity.albumIds.push(a.id);
      }
    }
  }
  return { artists: [...artists.values()], albums: [...albums.values()] };
}
