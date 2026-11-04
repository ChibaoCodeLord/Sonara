export const libraryFields = ['profile', 'playlists', 'savedAlbumIds', 'savedPlaylistIds', 'followedShowIds', 'savedEpisodeIds', 'followedUserIds', 'folders', 'history', 'episodeProgress', 'listeningActivity', 'libraryTestSeed'];
export const libraryIdentity = session => session?.email?.trim().toLowerCase() || '__guest__';
export const snapshotLibrary = (app, player) => ({ ...Object.fromEntries(libraryFields.map(key => [key, app[key]])), likedSongIds: player.likedSongIds, followedArtistIds: player.followedArtistIds });
export function emptyLibrary() {
  return { profile: { name: 'Người nghe', bio: '', avatar: '/images/catalog-placeholder.svg' }, playlists: [], savedAlbumIds: [], savedPlaylistIds: [], followedShowIds: [], savedEpisodeIds: [], followedUserIds: [], folders: [], history: [], episodeProgress: {}, listeningActivity: {}, libraryTestSeed: null, likedSongIds: [], followedArtistIds: [] };
}
