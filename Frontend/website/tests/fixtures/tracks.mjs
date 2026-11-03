// Test fixtures only; these are never imported by the application.
export const songsData = [1,2,3].map(n => ({ id:`test_track_${n}`, title:`Test track ${n}`, artist:'Test artist',
  provider:'audio', audioUrl:`https://example.test/audio/${n}.mp3`, durationSeconds:180+n, lyrics:[] }));
export const youtubeTrack = { id:'test_youtube', title:'Test video', provider:'youtube', youtubeId:'abcdefghijk', durationSeconds:180 };
export const blockedTrack = { ...youtubeTrack, id:'test_blocked', embedCheck:{status:'blocked'} };
