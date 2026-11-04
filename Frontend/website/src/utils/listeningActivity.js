export const DAILY_GOAL_SECONDS = 30;
export const localDay = (date = new Date()) => `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
export function shiftDay(key, offset) {
  const [y, m, d] = key.split('-').map(Number);
  return localDay(new Date(y, m - 1, d + offset, 12));
}
// Split real playback time at local midnight, including DST changes.
export function addListening(activity, start, end) {
  if (!Number.isFinite(start) || !Number.isFinite(end) || end <= start || end - start > 15000) return activity;
  const result = { ...activity };
  let cursor = start;
  while (cursor < end) {
    const date = new Date(cursor);
    const midnight = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1).getTime();
    const until = Math.min(end, midnight), key = localDay(date);
    result[key] = Math.min(86400, (Number(result[key]) || 0) + (until - cursor) / 1000);
    cursor = until;
  }
  return result;
}
export function activityStats(activity, today = localDay()) {
  const days = Object.keys(activity).filter(key => key <= today && activity[key] >= DAILY_GOAL_SECONDS).sort();
  let longest = 0, run = 0, previous;
  for (const day of days) {
    run = previous && shiftDay(previous, 1) === day ? run + 1 : 1;
    longest = Math.max(longest, run); previous = day;
  }
  let cursor = activity[today] >= DAILY_GOAL_SECONDS ? today : shiftDay(today, -1), current = 0;
  while (activity[cursor] >= DAILY_GOAL_SECONDS) { current++; cursor = shiftDay(cursor, -1); }
  return { current, longest, total: days.length, todaySeconds: Number(activity[today]) || 0 };
}
export function calendarDays(year, today = localDay()) {
  const first = `${year}-01-01`, last = `${year}-12-31`;
  const start = shiftDay(first, -new Date(year, 0, 1, 12).getDay());
  const days = [];
  for (let day = start; day <= last || days.length % 7 !== 0; day = shiftDay(day, 1)) {
    days.push({ key: day, inYear: day >= first && day <= last, future: day > today });
  }
  return days;
}
export const activityLevel = seconds => seconds >= 1800 ? 4 : seconds >= 600 ? 3 : seconds >= 120 ? 2 : seconds >= DAILY_GOAL_SECONDS ? 1 : 0;

// Both clocks must move normally: scrubbing, buffering and long suspended gaps earn no time.
export function playbackInterval(previous, sample) {
  if (!previous || !sample.active || !previous.active) return null;
  const wall = (sample.wall - previous.wall) / 1000;
  const media = sample.media - previous.media;
  if (wall <= 0 || wall > 5 || media <= 0 || media > wall * 1.3 + 0.15) return null;
  const seconds = Math.min(wall, media);
  return [sample.wall - seconds * 1000, sample.wall];
}
