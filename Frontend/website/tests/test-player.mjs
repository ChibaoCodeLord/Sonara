import assert from 'node:assert/strict';
import { usePlayerStore } from '../src/store/usePlayerStore.js';
import { songsData } from './fixtures/tracks.mjs';

const initial = usePlayerStore.getState();
const state = () => usePlayerStore.getState();
try {
  state().setQueue(songsData.slice(0, 2));
  state().setQueue([]);
  assert.equal(state().currentSong.id, songsData[0].id, 'Empty playlist keeps current track');

  usePlayerStore.setState({ repeatMode: 'one', isShuffle: false });
  state().nextSong();
  assert.equal(state().currentSong.id, songsData[1].id, 'Next button skips even in repeat-one mode');
  state().setCurrentTime(10);
  state().nextSong({ automatic: true });
  assert.equal(state().currentSong.id, songsData[1].id);
  assert.equal(state().currentTime, 0, 'Automatic end repeats the same track');

  usePlayerStore.setState({ repeatMode: 'off' });
  state().nextSong({ automatic: true });
  assert.equal(state().isPlaying, false, 'Last track stops when repeat is off');

  state().playSong(songsData[2]);
  assert.equal(state().queue[state().queueIndex].id, songsData[2].id, 'Playing outside the queue preserves its index');
  const current = state().currentSong;
  usePlayerStore.setState({ queue: [] });
  state().prevSong();
  assert.equal(state().currentSong.id, current.id, 'Previous with empty queue is safe');
  console.log('Player state scenarios passed: 6');
} finally {
  usePlayerStore.setState(initial, true);
}
