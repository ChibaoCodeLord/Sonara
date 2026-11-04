import assert from 'node:assert/strict';
import test from 'node:test';
import { activityStats, addListening, calendarDays, playbackInterval, localDay, shiftDay } from '../src/utils/listeningActivity.js';
import { validYoutubeLink } from '../src/utils/mediaApi.js';
import { useAppStore } from '../src/store/useAppStore.js';
import { usePlayerStore } from '../src/store/usePlayerStore.js';
import { songsData } from './fixtures/tracks.mjs';

test('daily threshold, yesterday grace, longest streak and broken streak', () => {
  const days = { '2026-10-14': 30, '2026-10-15': 120, '2026-10-16': 600, '2026-10-17': 29.9 };
  assert.deepEqual(activityStats(days, '2026-10-17'), { current: 3, longest: 3, total: 3, todaySeconds: 29.9 });
  assert.equal(activityStats(days, '2026-10-18').current, 0);
  days['2026-10-17'] = 30; days['2026-10-18'] = 30;
  assert.equal(activityStats(days, '2026-10-18').current, 5);
});
test('playback splits at local midnight and ignores suspended gaps', () => {
  const start = new Date(2026, 9, 17, 23, 59, 58).getTime();
  assert.deepEqual(addListening({}, start, start + 5000), { '2026-10-17': 2, '2026-10-18': 3 });
  assert.deepEqual(addListening({}, start, start + 60000), {});
  assert.deepEqual(addListening({}, NaN, start), {});
  assert.equal(localDay(new Date(2026, 0, 1, 0, 0)), '2026-01-01');
});
test('calendar includes leap day, year boundaries, full weeks and future flags', () => {
  assert.equal(shiftDay('2024-02-28', 1), '2024-02-29');
  assert.equal(shiftDay('2026-12-31', 1), '2027-01-01');
  const leap = calendarDays(2024, '2024-10-18');
  assert.equal(leap.filter(day => day.inYear).length, 366);
  assert.equal(leap.length % 7, 0);
  assert.equal(calendarDays(2026).filter(day => day.inYear).length, 365);
  assert(leap.find(day => day.key === '2024-12-31').future);
});
test('seeking, paused audio, buffering and suspended timer do not earn activity', () => {
  const previous = { wall: 1000, media: 10, active: true };
  assert.deepEqual(playbackInterval(previous, { wall: 2000, media: 11, active: true }), [1000, 2000]);
  for (const sample of [{ wall: 2000, media: 40, active: true }, { wall: 2000, media: 2, active: true }, { wall: 2000, media: 10, active: true }, { wall: 2000, media: 11, active: false }, { wall: 20000, media: 29, active: true }]) assert.equal(playbackInterval(previous, sample), null);
});
test('YouTube link validation prevents arbitrary URLs, credentials and playlist-only links', () => {
  assert(validYoutubeLink('https://youtu.be/BaW_jenozKc?si=test'));
  assert(validYoutubeLink('https://youtube.com/shorts/BaW_jenozKc'));
  for (const value of ['http://youtube.com/watch?v=BaW_jenozKc', 'https://youtube.com.evil.test/watch?v=BaW_jenozKc', 'https://user@youtube.com/watch?v=BaW_jenozKc', 'https://youtube.com/playlist?list=1', 'file:///test', 'https://127.0.0.1/']) assert(!validYoutubeLink(value));
});
test('daily activity accumulates independently from deduplicated history', () => {
  const initial = useAppStore.getState();
  try {
    useAppStore.setState({ listeningActivity: {} });
    const time = new Date(2026, 9, 18, 12).getTime();
    for (let i = 0; i < 30; i++) useAppStore.getState().recordListening(time + i * 1000, time + (i + 1) * 1000);
    useAppStore.getState().recordListen('test'); useAppStore.getState().clearHistory();
    assert.equal(useAppStore.getState().listeningActivity['2026-10-18'], 30);
  } finally { useAppStore.setState(initial, true); }
});
test('deleting imported audio removes duplicates and retains correct queue selection', () => {
  const initial = usePlayerStore.getState(), player = () => usePlayerStore.getState();
  const custom = { ...songsData[0], id: 'youtube_test' };
  try {
    player().setQueue([songsData[0], custom, custom, songsData[1]], 3); player().forgetSong(custom.id);
    assert.equal(player().queueIndex, 1); assert.equal(player().currentSong.id, songsData[1].id);
    player().setQueue([custom, songsData[1]], 0); player().forgetSong(custom.id);
    assert.equal(player().currentSong.id, songsData[1].id); assert.equal(player().isPlaying, false);
    player().setQueue([custom]); player().forgetSong(custom.id);
    assert.equal(player().currentSong, null); assert.equal(player().queue.length, 0);
  } finally { usePlayerStore.setState(initial, true); }
});
