import mongoose from 'mongoose';
import { connectDB } from '../src/config/db.js';
import {
  User,
  Artist,
  Album,
  Track,
  TrackArtist,
  AlbumTrack,
  AlbumArtist,
  Playlist,
  PlaylistTrack,
  LikedTrack,
  FollowedArtist,
  ListeningHistory,
  PlaybackState,
} from '../src/models/index.js';

async function initDatabase() {
  console.log('>>> [1/4] Đang kết nối tới MongoDB Atlas...');
  await connectDB();

  console.log('>>> [2/4] Đang khởi tạo các chỉ mục (Indexes) cho 13 bảng...');
  const models = [
    User,
    Artist,
    Album,
    Track,
    TrackArtist,
    AlbumTrack,
    AlbumArtist,
    Playlist,
    PlaylistTrack,
    LikedTrack,
    FollowedArtist,
    ListeningHistory,
    PlaybackState,
  ];

  for (const model of models) {
    await model.createIndexes();
    console.log(`  ✓ Đã khởi tạo index cho collection: "${model.collection.name}"`);
  }

  console.log('>>> [3/4] Đang kiểm tra và đẩy dữ liệu mẫu khởi tạo...');
  // 1. Tạo User mẫu
  let user = await User.findOne({ email: 'sonara.demo@gmail.com' });
  if (!user) {
    user = await User.create({
      email: 'sonara.demo@gmail.com',
      password_hash: 'Demo123456',
      display_name: 'Lê Hải Đăng',
      avatar_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
      country: 'VN',
    });
    console.log('  + Đã tạo User mẫu:', user.display_name);
  }

  // 2. Tạo Artist mẫu
  let artist = await Artist.findOne({ name: 'Vũ.' });
  if (!artist) {
    artist = await Artist.create({
      name: 'Vũ.',
      image_url: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500',
      biography: 'Hoàng Thái Vũ (sinh ngày 3 tháng 10 năm 1995), thường được biết đến với nghệ danh Vũ., là một ca sĩ kiêm sáng tác nhạc indie pop người Việt Nam.',
      verified: true,
      followers_count: 520000,
    });
    console.log('  + Đã tạo Artist mẫu:', artist.name);
  }

  // 3. Tạo Album mẫu
  let album = await Album.findOne({ title: 'Bảo Tàng Của Nuối Tiếc' });
  if (!album) {
    album = await Album.create({
      title: 'Bảo Tàng Của Nuối Tiếc',
      album_type: 'album',
      cover_url: 'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=500',
      release_date: new Date('2024-09-27'),
      label: 'Warner Music Vietnam',
      total_tracks: 10,
    });
    console.log('  + Đã tạo Album mẫu:', album.title);
  }

  // 4. Tạo Track mẫu
  let track = await Track.findOne({ title: 'Từng Quen' });
  if (!track) {
    track = await Track.create({
      title: 'Từng Quen',
      duration_ms: 198000,
      explicit: false,
      isrc: 'VNWAR2300001',
      popularity: 88,
      preview_url: 'https://example.com/preview/tung-quen.mp3',
      audio_url: 'https://example.com/audio/tung-quen.mp3',
      status: 'active',
    });
    console.log('  + Đã tạo Track mẫu:', track.title);
  }

  // 5. Tạo quan hệ TrackArtist
  await TrackArtist.findOneAndUpdate(
    { track_id: track._id, artist_id: artist._id },
    { role: 'main_artist' },
    { upsert: true }
  );

  // 6. Tạo quan hệ AlbumTrack
  await AlbumTrack.findOneAndUpdate(
    { album_id: album._id, track_id: track._id },
    { disc_number: 1, track_number: 1 },
    { upsert: true }
  );

  // 7. Tạo quan hệ AlbumArtist
  await AlbumArtist.findOneAndUpdate(
    { album_id: album._id, artist_id: artist._id },
    {},
    { upsert: true }
  );

  // 8. Tạo Playlist mẫu
  let playlist = await Playlist.findOne({ name: 'Sonara Chill Mix' });
  if (!playlist) {
    playlist = await Playlist.create({
      owner_id: user._id,
      name: 'Sonara Chill Mix',
      description: 'Tuyển tập giai điệu acoustic và lo-fi nhẹ nhàng',
      image_url: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=500',
      is_public: true,
      collaborative: false,
    });
    console.log('  + Đã tạo Playlist mẫu:', playlist.name);
  }

  // 9. Tạo PlaylistTrack
  await PlaylistTrack.findOneAndUpdate(
    { playlist_id: playlist._id, track_id: track._id },
    { added_by: user._id, position: 1 },
    { upsert: true }
  );

  // 10. Tạo LikedTrack
  await LikedTrack.findOneAndUpdate(
    { user_id: user._id, track_id: track._id },
    { added_at: new Date() },
    { upsert: true }
  );

  // 11. Tạo FollowedArtist
  await FollowedArtist.findOneAndUpdate(
    { user_id: user._id, artist_id: artist._id },
    { followed_at: new Date() },
    { upsert: true }
  );

  // 12. Tạo ListeningHistory
  await ListeningHistory.create({
    user_id: user._id,
    track_id: track._id,
    listened_ms: 198000,
    completed: true,
    source: 'home_recommend',
    played_at: new Date(),
  });

  // 13. Tạo PlaybackState
  await PlaybackState.findOneAndUpdate(
    { user_id: user._id },
    {
      current_track_id: track._id,
      position_ms: 45000,
      is_playing: true,
      repeat_mode: 'off',
      shuffle: false,
      queue: [track._id],
      updated_at: new Date(),
    },
    { upsert: true }
  );

  console.log('>>> [4/4] KHỞI TẠO THÀNH CÔNG! Toàn bộ 13 Collections đã được đẩy lên MongoDB Atlas!');
  await mongoose.disconnect();
  process.exit(0);
}

initDatabase().catch((err) => {
  console.error('>>> [LỖI KHỞI TẠO CSDL]:', err);
  process.exit(1);
});
