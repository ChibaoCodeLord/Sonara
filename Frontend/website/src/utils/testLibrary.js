import { deriveCatalogEntities, playableTrack } from './catalogEntities.js';

export const testLibraryEmail = 'quocdat19991712@gmail.com';
export const testLibraryVersion = 'quocdat-library-v1';
export const normalizeEmail = email => String(email || '').trim().toLowerCase();
const normalized = value => String(value || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[đĐ]/g, 'd').toLowerCase();
const unique = values => [...new Set(values)];

export function createTestLibrary(tracks, { email, owner = 'Quốc Đạt', dataset = '', now = Date.now() } = {}) {
  if (normalizeEmail(email) !== testLibraryEmail) return null;
  const playable = tracks.filter(track => track.playbackKind === 'full' && track.audioUrl && playableTrack(track));
  if (playable.length < 24) return null;
  const vn = playable.filter(track => track.region === 'VN');
  const select = (preferred, offset = 0) => unique([...preferred, ...vn.slice(offset), ...playable.slice(offset), ...playable].map(track => track.id)).slice(0, 12);
  const artistMatches = pattern => playable.filter(track => pattern.test(normalized(`${track.artist} ${track.title} ${track.genre}`)));
  const definitions = [
    { key: 'vpop', title: 'V-Pop yêu thích', description: 'Dữ liệu test · Những giai điệu Việt để thử phát nhạc và chỉnh sửa playlist.', cover: 'vpop', folder: 'viet', songs: select(artistMatches(/son tung|my tam|hoa minzy|hoang thuy linh|bich phuong/)) },
    { key: 'chill', title: 'Chill cuối ngày', description: 'Dữ liệu test · Một playlist riêng tư để thử tìm kiếm, thêm và sắp xếp bài.', cover: 'relax', folder: 'chill', songs: select(artistMatches(/vu\b|ngot|den vau|chill|ambient|ballad/), 20) },
    { key: 'cafe', title: 'Cà phê sáng', description: 'Dữ liệu test · Những bản nhạc nhẹ để thử thư mục và chế độ hiển thị thư viện.', cover: 'cafe', folder: 'chill', songs: select(artistMatches(/acoustic|folk|indie|vu cat tuong|le cat trong ly/), 40) },
    { key: 'energy', title: 'Nạp năng lượng', description: 'Dữ liệu test · Nhịp điệu sôi động để thử hàng đợi và phát trộn.', cover: 'workout', folder: 'viet', songs: select(artistMatches(/hieuthuhai|binz|karik|rap|house|edm|dance/), 60) }
  ];
  const id = key => `test_quocdat_v1_${key}`;
  const playlists = definitions.map((item, index) => ({ id: `playlist_${id(item.key)}`, title: item.title, description: item.description,
    coverUrl: `/images/genres/${item.cover}.webp`, songIds: item.songs, owned: true, owner, ownerEmail: testLibraryEmail,
    isPublic: index === 0, folderId: id(`folder_${item.folder}`), tag: 'DỮ LIỆU TEST' }));
  const selectedIds = unique(definitions.flatMap(item => item.songs));
  const likedSongIds = unique([...selectedIds, ...vn.map(track => track.id), ...playable.map(track => track.id)]).slice(0,24);
  const entities = deriveCatalogEntities(playable);
  const savedAlbumIds = entities.albums.slice(0,5).map(album => album.id);
  const followedArtistIds = entities.artists.slice(0,6).map(artist => artist.id);
  const history = likedSongIds.slice(0,15).map((songId,index) => ({ songId, at: now - (index + 1) * 2 * 60 * 60 * 1000, isTestData: true }));
  return { playlists, likedSongIds, followedArtistIds, savedAlbumIds, history,
    folders: [{ id: id('folder_viet'), title: 'Nhạc Việt của Đạt' }, { id: id('folder_chill'), title: 'Góc thư giãn' }],
    marker: { version: testLibraryVersion, dataset, createdAt: now, counts: { playlists: playlists.length, liked: likedSongIds.length, albums: savedAlbumIds.length, artists: followedArtistIds.length, history: history.length } } };
}
