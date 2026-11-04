import test from 'node:test';
import assert from 'node:assert/strict';
import { createTestLibrary, testLibraryEmail } from '../src/utils/testLibrary.js';
import { useAppStore } from '../src/store/useAppStore.js';
import { usePlayerStore } from '../src/store/usePlayerStore.js';
import { emptyLibrary } from '../src/utils/localLibrary.js';

const tracks = Array.from({ length: 80 }, (_, i) => ({ id: `catalog_${i}`, title: `Bài ${i}`, artist: ['Hòa Minzy', 'Ngọt', 'Binz', 'Acoustic Artist'][i % 4],
  audioUrl: `https://example.test/${i}.mp3`, playbackKind: 'full', region: i < 60 ? 'VN' : 'INTL',
  artists: [{ id: `artist_${i % 8}`, name: `Nghệ sĩ ${i % 8}` }], albumInfo: { id: `album_${i % 10}`, title: `Album ${i % 10}` } }));
const fixture = () => createTestLibrary(tracks, { email: testLibraryEmail, dataset: 'test', now: 1000000000 });
const app = () => useAppStore.getState(), player = () => usePlayerStore.getState();

test('test library is limited to the specified email and complete audio records', () => {
  assert.equal(createTestLibrary(tracks, { email: 'other@example.test' }), null);
  assert.equal(createTestLibrary(tracks.slice(0, 23), { email: testLibraryEmail }), null);
  assert.equal(createTestLibrary(tracks.map(t => ({ ...t, playbackKind: 'preview' })), { email: testLibraryEmail }), null);
  const data = fixture();
  assert.deepEqual(data.marker.counts, { playlists: 4, liked: 24, albums: 5, artists: 6, history: 15 });
  assert.equal(data.folders.length, 2);
  for (const playlist of data.playlists) {
    assert.equal(playlist.songIds.length, 12); assert.equal(new Set(playlist.songIds).size, 12);
    assert(playlist.songIds.every(id => tracks.some(t => t.id === id && t.audioUrl)));
    assert(data.folders.some(folder => folder.id === playlist.folderId));
  }
  assert(data.history.every(entry => entry.isTestData));
});

test('seeding preserves existing data, runs once, survives hydration and isolates local accounts', async () => {
  const initialApp = app(), initialPlayer = player();
  try {
    useAppStore.setState({ ...emptyLibrary(), session: null, accountLibraries: {} });
    usePlayerStore.setState({ likedSongIds: ['guest-like'], followedArtistIds: [] });
    assert.equal(app().seedTestLibrary(fixture()), false);
    app().signInDemo('Đạt', testLibraryEmail.toUpperCase());
    const existing = app().createPlaylist({ title: 'Giữ playlist này', songIds: ['catalog_79'] });
    app().recordListen('catalog_0');
    usePlayerStore.setState({ likedSongIds: ['existing-like'], followedArtistIds: ['existing-artist'] });
    assert.equal(app().seedTestLibrary(fixture()), true);
    assert.equal(app().playlists.length, 5); assert(app().playlists.some(p => p.id === existing));
    assert.equal(app().history.length, 15); assert.equal(app().history[0].isTestData, undefined);
    assert.equal(player().likedSongIds.length, 25); assert(player().followedArtistIds.includes('existing-artist'));
    assert.equal(player().currentSong, null); assert.deepEqual(app().listeningActivity, {});
    app().deletePlaylist(fixture().playlists[0].id);
    usePlayerStore.setState({ likedSongIds: player().likedSongIds.filter(id => id !== 'catalog_0') });
    const expectedLikes = [...player().likedSongIds];
    assert.equal(app().seedTestLibrary(fixture()), false);
    assert.equal(app().playlists.length, 4);
    await useAppStore.persist.rehydrate(); await usePlayerStore.persist.rehydrate();
    assert.equal(app().playlists.length, 4); assert.deepEqual(player().likedSongIds, expectedLikes);
    app().signOut(); assert.equal(app().libraryTestSeed, null); assert.equal(app().playlists.length, 0);
    assert.deepEqual(player().likedSongIds, ['guest-like']);
    app().signInDemo('Other', 'other@example.test');
    assert.equal(app().seedTestLibrary(fixture()), false); assert.deepEqual(player().likedSongIds, []);
    const other = app().createPlaylist({ title: 'Other account' });
    app().signInDemo('Đạt', testLibraryEmail);
    assert.equal(app().playlists.length, 4); assert(!app().playlists.some(p => p.id === other));
    assert.deepEqual(player().likedSongIds, expectedLikes); assert.equal(app().seedTestLibrary(fixture()), false);
    app().signInDemo('Other', 'other@example.test'); assert(app().playlists.some(p => p.id === other));
  } finally { useAppStore.setState(initialApp, true); usePlayerStore.setState(initialPlayer, true); }
});
