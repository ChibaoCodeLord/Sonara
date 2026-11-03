import test from 'node:test';
import assert from 'node:assert/strict';
import { youtubeAllTracks, youtubeTracks, youtubePlaylists } from '../src/data/youtubeCatalog.js';
import { usePlayerStore } from '../src/store/usePlayerStore.js';
import { songsData, youtubeTrack, blockedTrack } from './fixtures/tracks.mjs';

test('legacy YouTube catalog and playlists are empty after backend migration', () => {
  assert.deepEqual(youtubeAllTracks, []); assert.deepEqual(youtubeTracks, []); assert.deepEqual(youtubePlaylists, []);
});
test('blocked embeds cannot be played or queued, including curated mixed queues with duplicate positions', () => {
  const initial = usePlayerStore.getState(), state = () => usePlayerStore.getState();
  const allowed = youtubeTrack, blocked = blockedTrack;
  assert(blocked);
  try {
    state().setQueue([allowed, blocked, allowed], 2);
    assert.equal(state().queue.length, 2); assert.equal(state().queueIndex, 1);
    state().playSong(blocked); assert.equal(state().currentSong.id, allowed.id);
    state().addToQueue(blocked); assert.equal(state().queue.length, 2);
    state().setQueue([blocked]); assert.equal(state().queue.length, 2);
  } finally { usePlayerStore.setState(initial, true); }
});
test('duration remains unknown until the iframe supplies it; one-second explicit seeks have their own revision', () => {
  const initial = usePlayerStore.getState(), state = () => usePlayerStore.getState();
  try {
    state().playSong({ ...youtubeTrack, durationSeconds: null }); assert.equal(state().duration, 0);
    state().setDuration(180); const revision = state().seekRevision; state().seekTo(1);
    assert.equal(state().currentTime, 1); assert.equal(state().seekRevision, revision + 1);
    state().setCurrentTime(2); assert.equal(state().seekRevision, revision + 1);
    state().seekTo(NaN); assert.equal(state().currentTime, 2);
    state().playSong(songsData[0]); assert.equal(state().duration, songsData[0].durationSeconds);
  } finally { usePlayerStore.setState(initial, true); }
});
