import { Track, Artist, Album, TrackArtist, AlbumTrack, AlbumArtist } from '../models/index.js';
const defaultModels = { Track, Artist, Album, TrackArtist, AlbumTrack, AlbumArtist };

// Additive upserts preserve uploads, lyrics, likes, users and existing playlist references.
export async function upsertSpotifyTrack(data, models = defaultModels) {
  const { Track, Artist, Album, TrackArtist, AlbumTrack, AlbumArtist } = models;
  const albumData = data.spotify_metadata.album;
  const album = await Album.findOneAndUpdate({ spotify_id: albumData.spotify_id }, { $set: {
    spotify_id: albumData.spotify_id, spotify_url: albumData.url, title: albumData.title,
    album_type: albumData.album_type, cover_url: albumData.cover_url,
    release_date: albumData.release_date ? new Date(albumData.release_date) : null,
    release_date_precision: albumData.release_date_precision, total_tracks: albumData.total_tracks
  } }, { upsert: true, new: true, runValidators: true });
  const { status, genre, ...metadata } = data;
  const track = await Track.findOneAndUpdate({ spotify_id: data.spotify_id }, { $set: metadata, $setOnInsert: { status, genre } }, { upsert: true, new: true, runValidators: true });
  for (const [index, artistData] of data.spotify_metadata.artists.entries()) {
    const artist = await Artist.findOneAndUpdate({ spotify_id: artistData.spotify_id }, { $set: { name: artistData.name, spotify_id: artistData.spotify_id, spotify_url: artistData.url } }, { upsert: true, new: true, runValidators: true });
    await TrackArtist.updateOne({ track_id: track._id, artist_id: artist._id }, { $set: { role: index === 0 ? 'main_artist' : 'featured_artist' } }, { upsert: true });
    await AlbumArtist.updateOne({ album_id: album._id, artist_id: artist._id }, { $setOnInsert: { album_id: album._id, artist_id: artist._id } }, { upsert: true });
  }
  await AlbumTrack.updateOne({ album_id: album._id, track_id: track._id }, { $set: { track_number: data.spotify_metadata.track_number, disc_number: data.spotify_metadata.disc_number } }, { upsert: true });
  return track;
}

export async function saveYouTubeMatch(spotifyId, match, models = defaultModels) {
  return models.Track.updateOne({ spotify_id: spotifyId }, { $set: { youtube: match } }, { runValidators: true });
}

export async function upsertMusicBrainzTrack(data, models = defaultModels) {
  const { Track, Artist, Album, TrackArtist, AlbumTrack, AlbumArtist } = models;
  const metadata = data.musicbrainz_metadata;
  const track = await Track.findOneAndUpdate({ musicbrainz_id: data.musicbrainz_id }, { $set: data, $setOnInsert: { genre: '', status: 'active' } }, { upsert: true, new: true, runValidators: true });
  let album;
  if (metadata.album) {
    const source = metadata.album;
    album = await Album.findOneAndUpdate({ musicbrainz_id: source.musicbrainz_id }, { $set: {
      musicbrainz_id: source.musicbrainz_id, musicbrainz_url: source.url, title: source.title,
      album_type: source.album_type, release_date: source.release_date && Number.isFinite(Date.parse(source.release_date)) ? new Date(source.release_date) : null,
      release_date_precision: source.release_date_precision, total_tracks: source.total_tracks
    } }, { upsert: true, new: true, runValidators: true });
    if (metadata.track_number) await AlbumTrack.updateOne({ album_id: album._id, track_id: track._id }, { $set: { track_number: metadata.track_number, disc_number: metadata.disc_number } }, { upsert: true });
  }
  for (const [index, source] of metadata.artists.entries()) {
    const artist = await Artist.findOneAndUpdate({ musicbrainz_id: source.musicbrainz_id }, { $set: { musicbrainz_id: source.musicbrainz_id, musicbrainz_url: source.url, name: source.name } }, { upsert: true, new: true, runValidators: true });
    await TrackArtist.updateOne({ track_id: track._id, artist_id: artist._id }, { $set: { role: index === 0 ? 'main_artist' : 'featured_artist' } }, { upsert: true });
    if (album) await AlbumArtist.updateOne({ album_id: album._id, artist_id: artist._id }, { $setOnInsert: { album_id: album._id, artist_id: artist._id } }, { upsert: true });
  }
  return track;
}

export async function saveMusicBrainzYouTubeMatch(id, match, models = defaultModels) {
  return models.Track.updateOne({ musicbrainz_id: id }, { $set: { youtube: match } }, { runValidators: true });
}

export function toWebsiteTrack(track) {
  if (track.source_key && track.catalog_metadata) {
    const m = track.catalog_metadata;
    const source = track.catalog_source;
    const full = Boolean(track.audio_url);
    const preview = Boolean(track.preview_url);
    return {
      id: `catalog_${track._id}`, databaseId: String(track._id), title: track.title,
      artist: (m.artists || []).map(a => a.name).join(', ') || 'Chưa có thông tin nghệ sĩ',
      artists: (m.artists || []).map(a => ({ id: `artist_${source}_${a.id}`, sourceId: a.id, name: a.name, imageUrl: a.image_url || '' })),
      album: m.album?.title || '', albumSourceId: m.album?.id || null,
      albumInfo: m.album ? { ...m.album, id: `album_${source}_${m.album.id}`, sourceId: m.album.id } : null,
      genre: track.genre || '', coverUrl: track.cover_url || '/images/catalog-placeholder.svg',
      durationSeconds: track.duration_ms ? track.duration_ms / 1000 : 0,
      provider: full ? ['youtube','local'].includes(source) ? 'audio' : source : 'metadata', audioUrl: full ? track.audio_url : '', previewUrl: track.preview_url || '',
      playbackKind: full ? 'full' : preview ? 'preview' : 'metadata', canPlay: full,
      metadataSource: source, metadataUrl: m.source_url || '', sourceUrl: m.source_url || '',
      region: m.region || 'INTL', licenseUrl: m.license_url || '', licenseLabel: m.license_label || '',
      downloadAllowed: m.download_allowed === true, contentKind: m.content_kind,
      collection: m.source_metadata?.collection || '', fetchedAt: m.fetched_at,
      isLossless: /flac|wav/i.test(m.source_metadata?.format || m.source_metadata?.file_name || ''),
      lyrics: (track.synced_lyrics || []).map(line => ({ time: (line.time_ms || 0) / 1000, text: line.text })),
      dataset: track.catalog_dataset
    };
  }
  if (track.catalog_source === 'archive') {
    const metadata = track.archive_metadata || {};
    return {
      id: `archive_${track.archive_id}`, databaseId: String(track._id), title: track.title, artist: metadata.artist,
      album: metadata.album, genre: track.genre, coverUrl: track.cover_url || '/images/catalog-placeholder.svg',
      durationSeconds: track.duration_ms / 1000, provider: 'archive', audioUrl: track.audio_url,
      region: metadata.region || 'INTL', metadataSource: 'archive', metadataUrl: metadata.item_url,
      sourceUrl: metadata.item_url, licenseUrl: metadata.license_url, licenseLabel: metadata.license_label,
      collection: metadata.collection, audioFormat: metadata.format, fetchedAt: metadata.fetched_at,
      isLossless: /flac|wav/i.test(metadata.file_name || ''), lyrics: []
    };
  }
  if (track.catalog_source === 'audius') return {
    id: `audius_${track.audius_id}`, databaseId: String(track._id), title: track.title, artist: track.audius_metadata?.artist || 'Audius',
    album: 'Audius', genre: track.genre, coverUrl: track.cover_url || '/images/catalog-placeholder.svg',
    durationSeconds: track.duration_ms / 1000, provider: 'audius', audioUrl: track.audio_url,
    region: track.audius_metadata?.region || 'INTL', metadataSource: 'audius', metadataUrl: track.audius_metadata?.url,
    sourceUrl: track.audius_metadata?.url, isLossless: false, lyrics: []
  };
  const matched = track.youtube?.status === 'matched';
  const nativeAudio = Boolean(track.audio_url && (!track.audio_cache?.source_url || track.audio_cache.source_url === track.youtube?.url));
  const source = track.catalog_source === 'musicbrainz' ? 'musicbrainz' : 'spotify';
  const metadata = track.musicbrainz_metadata || track.spotify_metadata;
  const sourceId = source === 'musicbrainz' ? track.musicbrainz_id : track.spotify_id;
  const metadataUrl = source === 'musicbrainz' ? track.musicbrainz_url : track.spotify_url;
  return {
    id: `${source}_${sourceId}`, databaseId: String(track._id), ...(source === 'musicbrainz' ? { musicbrainzId: sourceId, musicbrainzUrl: metadataUrl } : { spotifyId: sourceId, spotifyUrl: metadataUrl }),
    title: track.title, artist: (metadata?.artists || []).map(artist => artist.name).join(', '),
    album: metadata?.album?.title || '', coverUrl: track.cover_url || (matched ? `https://i.ytimg.com/vi/${track.youtube.video_id}/hqdefault.jpg` : '/images/catalog-placeholder.svg'),
    duration: matched ? track.youtube.duration_seconds : track.duration_ms / 1000,
    durationSeconds: nativeAudio ? track.audio_cache?.duration_seconds || track.duration_ms / 1000 : matched ? track.youtube.duration_seconds : track.duration_ms / 1000,
    durationText: '', region: metadata?.region || 'INTL',
    provider: nativeAudio ? 'audio' : matched ? 'youtube' : source, ...(nativeAudio ? { audioUrl: track.audio_url } : {}), metadataSource: source, metadataUrl,
    fetchedAt: metadata?.fetched_at,
    sourceUrl: matched ? track.youtube.url : metadataUrl,
    ...(matched ? { youtubeId: track.youtube.video_id, channelTitle: track.youtube.channel_title, ...(nativeAudio ? {} : { embedCheck: { status: track.youtube.playback_status === 'blocked' ? 'blocked' : track.youtube.playback_status === 'available' ? 'available' : 'unverified', checkedAt: track.youtube.playback_checked_at || track.youtube.checked_at } }) } : {}),
    matchStatus: track.youtube?.status || 'pending'
  };
}
