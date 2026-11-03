import 'package:flutter/material.dart';
import 'catalog_images.dart';
import 'catalog_models.dart';

class CatalogSearchResult {
  final List<CatalogSong> songs;
  final List<CatalogArtist> artists;
  final List<CatalogAlbum> albums;
  final List<CatalogPlaylist> playlists;

  const CatalogSearchResult({
    this.songs = const [],
    this.artists = const [],
    this.albums = const [],
    this.playlists = const [],
  });

  bool get isEmpty =>
      songs.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty;
}

/// In-memory music catalog shared by the mock services until the backend
/// REST API is wired in.
class MusicCatalog {
  MusicCatalog._();

  static const List<CatalogArtist> artists = [
    CatalogArtist(
      id: 'artist_dalab',
      name: 'Da LAB',
      avatarUrl: CatalogImages.artistDaLab,
      coverUrl: CatalogImages.bauTroiMoi,
      monthlyListenersText: '2.1M người nghe hàng tháng',
      followersText: '1.4M người theo dõi',
      bio:
          'Nhóm nhạc hip-hop/pop đến từ Hà Nội, nổi tiếng với những ca khúc tự sự ấm áp và giai điệu dễ ngân nga.',
      genres: ['V-Pop', 'Hip-hop', 'Lo-fi'],
    ),
    CatalogArtist(
      id: 'artist_vu',
      name: 'Vũ.',
      avatarUrl: CatalogImages.artistVu,
      coverUrl: CatalogImages.duoiAnhHoangHon,
      monthlyListenersText: '3.6M người nghe hàng tháng',
      followersText: '2.8M người theo dõi',
      bio:
          '"Hoàng tử indie" với chất giọng trầm ấm, viết nhạc về những nỗi nhớ dịu dàng và các cuộc tình dang dở.',
      genres: ['Indie', 'Ballad'],
    ),
    CatalogArtist(
      id: 'artist_miule',
      name: 'Miu Lê',
      avatarUrl: CatalogImages.artistMiuLe,
      coverUrl: CatalogImages.chamVaoGiaiDieu,
      monthlyListenersText: '1.2M người nghe hàng tháng',
      followersText: '960K người theo dõi',
      bio: 'Ca sĩ, diễn viên với phong cách pop trong trẻo và giàu cảm xúc.',
      genres: ['V-Pop', 'Ballad'],
    ),
    CatalogArtist(
      id: 'artist_hoangdung',
      name: 'Hoàng Dũng',
      avatarUrl: CatalogImages.artistHoangDung,
      coverUrl: CatalogImages.conMuaMuaHa,
      monthlyListenersText: '2.4M người nghe hàng tháng',
      followersText: '1.9M người theo dõi',
      bio:
          'Giọng ca ballad với những bản tình ca mộc mạc, được yêu thích nhờ giai điệu dễ nhớ và ca từ chân thật.',
      genres: ['Ballad', 'Acoustic'],
    ),
    CatalogArtist(
      id: 'artist_sontung',
      name: 'Sơn Tùng M-TP',
      avatarUrl: CatalogImages.artistSonTung,
      coverUrl: CatalogImages.lacGiuaManDem,
      monthlyListenersText: '5.8M người nghe hàng tháng',
      followersText: '4.6M người theo dõi',
      bio:
          'Nghệ sĩ V-Pop hàng đầu với những bản hit phá vỡ kỷ lục và phong cách trình diễn đầy năng lượng.',
      genres: ['V-Pop', 'R&B', 'EDM'],
    ),
    CatalogArtist(
      id: 'artist_baoanh',
      name: 'Bảo Anh',
      avatarUrl: CatalogImages.tungLaCuaNhau,
      coverUrl: CatalogImages.tungLaCuaNhau,
      monthlyListenersText: '1.6M người nghe hàng tháng',
      followersText: '1.1M người theo dõi',
      bio: 'Giọng ca ballad nữ với những bản tình ca da diết.',
      genres: ['Ballad', 'V-Pop'],
    ),
    CatalogArtist(
      id: 'artist_phuongmychi',
      name: 'Phương Mỹ Chi',
      avatarUrl: CatalogImages.vuTruCoAnh,
      coverUrl: CatalogImages.vuTruCoAnh,
      monthlyListenersText: '1.3M người nghe hàng tháng',
      followersText: '870K người theo dõi',
      bio: 'Kết hợp chất liệu dân gian với âm nhạc điện tử hiện đại.',
      genres: ['V-Pop', 'Folk'],
    ),
    CatalogArtist(
      id: 'artist_thecassette',
      name: 'The Cassette',
      avatarUrl: CatalogImages.muaTrenTangThuong,
      coverUrl: CatalogImages.muaTrenTangThuong,
      monthlyListenersText: '640K người nghe hàng tháng',
      followersText: '410K người theo dõi',
      bio: 'Ban nhạc indie với âm thanh lo-fi hoài cổ, mộc mạc như cuộn băng cũ.',
      genres: ['Indie', 'Lo-fi'],
    ),
    CatalogArtist(
      id: 'artist_buitruonglinh',
      name: 'Bùi Trường Linh',
      avatarUrl: CatalogImages.khoaAnhMatLai,
      coverUrl: CatalogImages.khoaAnhMatLai,
      monthlyListenersText: '1.9M người nghe hàng tháng',
      followersText: '1.2M người theo dõi',
      bio: 'Nhạc sĩ trẻ với các bản ballad viral được ngân nga nhiều nhất tuần.',
      genres: ['Ballad', 'V-Pop'],
    ),
    CatalogArtist(
      id: 'artist_ducphuc',
      name: 'Đức Phúc',
      avatarUrl: CatalogImages.ngayDauTien,
      coverUrl: CatalogImages.ngayDauTien,
      monthlyListenersText: '1.7M người nghe hàng tháng',
      followersText: '1.5M người theo dõi',
      bio: 'Giọng ca pop ballad sáng, quen thuộc với các bản tình ca cưới.',
      genres: ['V-Pop', 'Ballad'],
    ),
    CatalogArtist(
      id: 'artist_sabrina',
      name: 'Sabrina Carpenter',
      avatarUrl: CatalogImages.espresso,
      coverUrl: CatalogImages.espresso,
      monthlyListenersText: '68M người nghe hàng tháng',
      followersText: '22M người theo dõi',
      bio: 'Ngôi sao pop quốc tế với loạt bản hit viral toàn cầu.',
      genres: ['Pop'],
    ),
  ];

  static const List<CatalogAlbum> albums = [
    CatalogAlbum(
      id: 'album_bau_troi_moi',
      title: 'Bầu Trời Mới',
      artistId: 'artist_dalab',
      artistName: 'Da LAB',
      coverUrl: CatalogImages.bauTroiMoi,
      year: 2024,
      label: 'Da LAB Music',
      type: 'Single',
      songIds: ['song_bau_troi_moi'],
    ),
    CatalogAlbum(
      id: 'album_thanh_am_dem',
      title: 'Thanh Âm Đêm',
      artistId: 'artist_dalab',
      artistName: 'Da LAB',
      coverUrl: CatalogImages.mixLofiNight,
      year: 2023,
      label: 'Da LAB Music',
      type: 'Album',
      songIds: ['song_giai_dieu_dem', 'song_bau_troi_moi', 'song_pho_cu'],
    ),
    CatalogAlbum(
      id: 'album_mot_van_nam',
      title: 'Một Vạn Năm',
      artistId: 'artist_vu',
      artistName: 'Vũ.',
      coverUrl: CatalogImages.duoiAnhHoangHon,
      year: 2022,
      label: 'Warner Music Vietnam',
      type: 'Album',
      quality: 'FLAC 24-bit / 192kHz',
      songIds: [
        'song_duoi_anh_hoang_hon',
        'song_tung_quen',
        'song_mot_van_nam',
      ],
    ),
    CatalogAlbum(
      id: 'album_25',
      title: '25',
      artistId: 'artist_hoangdung',
      artistName: 'Hoàng Dũng',
      coverUrl: CatalogImages.conMuaMuaHa,
      year: 2022,
      label: 'Hoàng Dũng Official',
      type: 'Album',
      songIds: ['song_con_mua_mua_ha', 'song_co_doi_lan', 'song_nang_tho'],
    ),
    CatalogAlbum(
      id: 'album_lac_giua_man_dem',
      title: 'Lạc Giữa Màn Đêm',
      artistId: 'artist_sontung',
      artistName: 'Sơn Tùng M-TP',
      coverUrl: CatalogImages.lacGiuaManDem,
      year: 2025,
      label: 'M-TP Entertainment',
      type: 'Single',
      songIds: ['song_lac_giua_man_dem'],
    ),
    CatalogAlbum(
      id: 'album_cham_vao_giai_dieu',
      title: 'Chạm Vào Giai Điệu',
      artistId: 'artist_miule',
      artistName: 'Miu Lê',
      coverUrl: CatalogImages.chamVaoGiaiDieu,
      year: 2024,
      label: 'Sonara Originals',
      type: 'EP',
      songIds: ['song_cham_vao_giai_dieu'],
    ),
    CatalogAlbum(
      id: 'album_tang_thuong',
      title: 'Tầng Thượng',
      artistId: 'artist_thecassette',
      artistName: 'The Cassette',
      coverUrl: CatalogImages.muaTrenTangThuong,
      year: 2023,
      label: 'Indie Garage',
      type: 'EP',
      songIds: ['song_mua_tren_tang_thuong'],
    ),
    CatalogAlbum(
      id: 'album_tung_la_cua_nhau',
      title: 'Từng Là Của Nhau',
      artistId: 'artist_baoanh',
      artistName: 'Bảo Anh',
      coverUrl: CatalogImages.tungLaCuaNhau,
      year: 2025,
      label: 'Bảo Anh Official',
      type: 'Single',
      songIds: ['song_tung_la_cua_nhau'],
    ),
    CatalogAlbum(
      id: 'album_vu_tru_co_anh',
      title: 'Vũ Trụ Có Anh',
      artistId: 'artist_phuongmychi',
      artistName: 'Phương Mỹ Chi',
      coverUrl: CatalogImages.vuTruCoAnh,
      year: 2025,
      label: 'PMC Entertainment',
      type: 'Single',
      songIds: ['song_vu_tru_co_anh'],
    ),
    CatalogAlbum(
      id: 'album_khoa_anh_mat_lai',
      title: 'Khóa Ánh Mắt Lại',
      artistId: 'artist_buitruonglinh',
      artistName: 'Bùi Trường Linh',
      coverUrl: CatalogImages.khoaAnhMatLai,
      year: 2025,
      label: 'BTL Music',
      type: 'Single',
      songIds: ['song_khoa_anh_mat_lai'],
    ),
    CatalogAlbum(
      id: 'album_ngay_dau_tien',
      title: 'Ngày Đầu Tiên',
      artistId: 'artist_ducphuc',
      artistName: 'Đức Phúc',
      coverUrl: CatalogImages.ngayDauTien,
      year: 2022,
      label: 'Đức Phúc Official',
      type: 'Single',
      songIds: ['song_ngay_dau_tien'],
    ),
    CatalogAlbum(
      id: 'album_short_n_sweet',
      title: "Short n' Sweet",
      artistId: 'artist_sabrina',
      artistName: 'Sabrina Carpenter',
      coverUrl: CatalogImages.espresso,
      year: 2024,
      label: 'Island Records',
      type: 'Album',
      songIds: ['song_espresso'],
    ),
  ];

  static const List<CatalogSong> songs = [
    CatalogSong(
      id: 'song_bau_troi_moi',
      title: 'Bầu Trời Mới',
      artistId: 'artist_dalab',
      artistName: 'Da LAB ft. Miu Lê',
      albumId: 'album_bau_troi_moi',
      albumTitle: 'Bầu Trời Mới',
      coverUrl: CatalogImages.bauTroiMoi,
      durationSeconds: 235,
      playsText: '12.4M',
      isExplicit: true,
    ),
    CatalogSong(
      id: 'song_giai_dieu_dem',
      title: 'Giai Điệu Đêm',
      artistId: 'artist_dalab',
      artistName: 'Da LAB',
      albumId: 'album_thanh_am_dem',
      albumTitle: 'Thanh Âm Đêm',
      coverUrl: CatalogImages.mixLofiNight,
      durationSeconds: 208,
      playsText: '4.1M',
      quality: 'HI-RES',
    ),
    CatalogSong(
      id: 'song_pho_cu',
      title: 'Phố Cũ',
      artistId: 'artist_dalab',
      artistName: 'Da LAB',
      albumId: 'album_thanh_am_dem',
      albumTitle: 'Thanh Âm Đêm',
      coverUrl: CatalogImages.mixLofiNight,
      durationSeconds: 221,
      playsText: '2.7M',
    ),
    CatalogSong(
      id: 'song_duoi_anh_hoang_hon',
      title: 'Dưới Ánh Hoàng Hôn',
      artistId: 'artist_vu',
      artistName: 'Vũ. ft. Min',
      albumId: 'album_mot_van_nam',
      albumTitle: 'Một Vạn Năm',
      coverUrl: CatalogImages.duoiAnhHoangHon,
      durationSeconds: 252,
      playsText: '9.8M',
      quality: 'HI-RES',
    ),
    CatalogSong(
      id: 'song_tung_quen',
      title: 'Từng Quen',
      artistId: 'artist_vu',
      artistName: 'Vũ.',
      albumId: 'album_mot_van_nam',
      albumTitle: 'Một Vạn Năm',
      coverUrl: CatalogImages.tungQuen,
      durationSeconds: 228,
      playsText: '15.2M',
    ),
    CatalogSong(
      id: 'song_mot_van_nam',
      title: 'Một Vạn Năm',
      artistId: 'artist_vu',
      artistName: 'Vũ.',
      albumId: 'album_mot_van_nam',
      albumTitle: 'Một Vạn Năm',
      coverUrl: CatalogImages.mixIndieViet,
      durationSeconds: 276,
      playsText: '6.3M',
      quality: 'HI-RES',
    ),
    CatalogSong(
      id: 'song_con_mua_mua_ha',
      title: 'Cơn Mưa Mùa Hạ',
      artistId: 'artist_hoangdung',
      artistName: 'Hoàng Dũng',
      albumId: 'album_25',
      albumTitle: '25',
      coverUrl: CatalogImages.conMuaMuaHa,
      durationSeconds: 241,
      playsText: '7.5M',
    ),
    CatalogSong(
      id: 'song_co_doi_lan',
      title: 'Có Đôi Lần',
      artistId: 'artist_hoangdung',
      artistName: 'Đức Trí, Hoàng Dũng',
      albumId: 'album_25',
      albumTitle: '25',
      coverUrl: CatalogImages.coDoiLan,
      durationSeconds: 290,
      playsText: '5.1M',
      quality: 'HI-RES',
    ),
    CatalogSong(
      id: 'song_nang_tho',
      title: 'Nàng Thơ',
      artistId: 'artist_hoangdung',
      artistName: 'Hoàng Dũng',
      albumId: 'album_25',
      albumTitle: '25',
      coverUrl: CatalogImages.mixAcoustic,
      durationSeconds: 254,
      playsText: '21.6M',
    ),
    CatalogSong(
      id: 'song_lac_giua_man_dem',
      title: 'Lạc Giữa Màn Đêm',
      artistId: 'artist_sontung',
      artistName: 'Sơn Tùng M-TP',
      albumId: 'album_lac_giua_man_dem',
      albumTitle: 'Lạc Giữa Màn Đêm',
      coverUrl: CatalogImages.lacGiuaManDem,
      durationSeconds: 219,
      playsText: '18.9M',
      isExplicit: true,
    ),
    CatalogSong(
      id: 'song_cham_vao_giai_dieu',
      title: 'Chạm Vào Giai Điệu',
      artistId: 'artist_miule',
      artistName: 'Miu Lê',
      albumId: 'album_cham_vao_giai_dieu',
      albumTitle: 'Chạm Vào Giai Điệu',
      coverUrl: CatalogImages.chamVaoGiaiDieu,
      durationSeconds: 213,
      playsText: '3.2M',
      quality: 'HI-RES',
    ),
    CatalogSong(
      id: 'song_mua_tren_tang_thuong',
      title: 'Mưa Trên Tầng Thượng',
      artistId: 'artist_thecassette',
      artistName: 'The Cassette',
      albumId: 'album_tang_thuong',
      albumTitle: 'Tầng Thượng',
      coverUrl: CatalogImages.muaTrenTangThuong,
      durationSeconds: 245,
      playsText: '1.9M',
      quality: 'HI-RES',
    ),
    CatalogSong(
      id: 'song_tung_la_cua_nhau',
      title: 'Từng Là Của Nhau',
      artistId: 'artist_baoanh',
      artistName: 'Bảo Anh, Táo',
      albumId: 'album_tung_la_cua_nhau',
      albumTitle: 'Từng Là Của Nhau',
      coverUrl: CatalogImages.tungLaCuaNhau,
      durationSeconds: 232,
      playsText: '11.7M',
    ),
    CatalogSong(
      id: 'song_vu_tru_co_anh',
      title: 'Vũ Trụ Có Anh',
      artistId: 'artist_phuongmychi',
      artistName: 'Phương Mỹ Chi',
      albumId: 'album_vu_tru_co_anh',
      albumTitle: 'Vũ Trụ Có Anh',
      coverUrl: CatalogImages.vuTruCoAnh,
      durationSeconds: 206,
      playsText: '8.2M',
    ),
    CatalogSong(
      id: 'song_khoa_anh_mat_lai',
      title: 'Khóa Ánh Mắt Lại',
      artistId: 'artist_buitruonglinh',
      artistName: 'Bùi Trường Linh',
      albumId: 'album_khoa_anh_mat_lai',
      albumTitle: 'Khóa Ánh Mắt Lại',
      coverUrl: CatalogImages.khoaAnhMatLai,
      durationSeconds: 224,
      playsText: '6.9M',
    ),
    CatalogSong(
      id: 'song_ngay_dau_tien',
      title: 'Ngày Đầu Tiên',
      artistId: 'artist_ducphuc',
      artistName: 'Đức Phúc',
      albumId: 'album_ngay_dau_tien',
      albumTitle: 'Ngày Đầu Tiên',
      coverUrl: CatalogImages.ngayDauTien,
      durationSeconds: 210,
      playsText: '24.3M',
    ),
    CatalogSong(
      id: 'song_espresso',
      title: 'Espresso',
      artistId: 'artist_sabrina',
      artistName: 'Sabrina Carpenter',
      albumId: 'album_short_n_sweet',
      albumTitle: "Short n' Sweet",
      coverUrl: CatalogImages.espresso,
      durationSeconds: 175,
      playsText: '1.6B',
      isExplicit: true,
    ),
  ];

  static const List<CatalogPlaylist> playlists = [
    CatalogPlaylist(
      id: 'ai_curated_01',
      title: 'Sonara AI Mix #01',
      subtitle: 'Sonara AI tuyển chọn',
      coverUrl: CatalogImages.sonaraAiMix,
    ),
    CatalogPlaylist(
      id: 'mix_1',
      title: 'Acoustic Tĩnh Lặng',
      subtitle: 'Phối lại bởi AI • 2.4k thính giả',
      coverUrl: CatalogImages.mixAcoustic,
    ),
    CatalogPlaylist(
      id: 'mix_2',
      title: 'Lo-Fi Giai Điệu Đêm',
      subtitle: 'Nhịp tim 68 BPM • Chillout',
      coverUrl: CatalogImages.mixLofiNight,
    ),
    CatalogPlaylist(
      id: 'mix_3',
      title: 'Indie Việt Tinh Tuyển',
      subtitle: 'Hoàng Dũng, Vũ, Trang & AI',
      coverUrl: CatalogImages.mixIndieViet,
    ),
    CatalogPlaylist(
      id: 'playlist_lofi_chill',
      title: 'Đêm Mưa & Lo-Fi Chill',
      subtitle: 'Sonara AI Mood • 42 bài',
      coverUrl: CatalogImages.playlistLofiChill,
    ),
    CatalogPlaylist(
      id: 'playlist_workout_135',
      title: 'Workout Energy Boost 135 BPM',
      subtitle: 'Phối tự động • 28 bài',
      coverUrl: CatalogImages.playlistWorkout,
    ),
    CatalogPlaylist(
      id: 'playlist_vpop_indie',
      title: 'V-Pop Indie Giai Điệu Buồn',
      subtitle: 'Tự tạo bởi bạn • 65 bài',
      coverUrl: CatalogImages.playlistVpopIndie,
    ),
  ];

  static const List<CatalogCategory> browseCategories = [
    CatalogCategory(
      id: 'mood',
      title: 'Tâm trạng',
      subtitle: 'Buồn, vui, hoài niệm',
      icon: Icons.mood_rounded,
      colors: [Color(0xFFB3122E), Color(0xFFFF4B4B)],
    ),
    CatalogCategory(
      id: 'chill',
      title: 'Thư giãn',
      subtitle: 'Nhẹ nhàng, bình yên',
      icon: Icons.spa_rounded,
      colors: [Color(0xFF3F6B5B), Color(0xFF7FB69E)],
    ),
    CatalogCategory(
      id: 'workout',
      title: 'Tập luyện',
      subtitle: '120-150 BPM',
      icon: Icons.fitness_center_rounded,
      colors: [Color(0xFFE85D04), Color(0xFFFFA62B)],
    ),
    CatalogCategory(
      id: 'cafe',
      title: 'Cafe',
      subtitle: 'Acoustic & Jazz',
      icon: Icons.local_cafe_rounded,
      colors: [Color(0xFF6F4E37), Color(0xFFB08968)],
    ),
    CatalogCategory(
      id: 'vpop',
      title: 'Nhạc Trẻ',
      subtitle: 'V-Pop thịnh hành',
      icon: Icons.star_rounded,
      colors: [Color(0xFF8B0012), Color(0xFFE9091F)],
    ),
    CatalogCategory(
      id: 'lofi',
      title: 'Lo-fi',
      subtitle: 'Học bài, làm việc',
      icon: Icons.headphones_rounded,
      colors: [Color(0xFF4A4E69), Color(0xFF9A8C98)],
    ),
    CatalogCategory(
      id: 'indie',
      title: 'Indie Việt',
      subtitle: 'Mộc mạc, tự sự',
      icon: Icons.music_note_rounded,
      colors: [Color(0xFF2B4162), Color(0xFF6B8CAE)],
    ),
    CatalogCategory(
      id: 'rap',
      title: 'Rap Việt',
      subtitle: 'Flow & Beat',
      icon: Icons.mic_external_on_rounded,
      colors: [Color(0xFF1A1A1A), Color(0xFF62656B)],
    ),
  ];

  static List<String> get tasteGenres => const [
        'Pop',
        'Ballad',
        'Indie',
        'R&B',
        'Lo-fi',
        'Rap Việt',
        'Acoustic',
        'EDM',
        'Jazz',
        'Rock',
        'Bolero',
        'K-Pop',
      ];

  static CatalogSong? songById(String id) {
    for (final song in songs) {
      if (song.id == id) return song;
    }
    return null;
  }

  static CatalogArtist artistById(String id) {
    return artists.firstWhere(
      (a) => a.id == id,
      orElse: () => artists.first,
    );
  }

  /// Resolves a free-form artist label (e.g. "Da LAB ft. Miu Lê") to the
  /// first catalog artist whose name appears in it.
  static CatalogArtist? artistByLabel(String label) {
    final normalized = normalize(label);
    for (final artist in artists) {
      if (normalized.contains(normalize(artist.name).replaceAll('.', ''))) {
        return artist;
      }
    }
    return null;
  }

  static CatalogAlbum albumById(String id) {
    return albums.firstWhere(
      (a) => a.id == id,
      orElse: () => albums.first,
    );
  }

  static CatalogAlbum? albumByTitle(String title) {
    final normalized = normalize(title);
    for (final album in albums) {
      if (normalize(album.title) == normalized) return album;
    }
    return null;
  }

  static List<CatalogSong> songsOfAlbum(String albumId) {
    final album = albumById(albumId);
    return album.songIds
        .map(songById)
        .whereType<CatalogSong>()
        .toList(growable: false);
  }

  static List<CatalogSong> topSongsOf(String artistId) {
    final own = songs.where((s) => s.artistId == artistId).toList();
    // Pad with featured tracks so every artist page has a full top list.
    final featured = songs.where((s) => s.artistId != artistId).take(5 - own.length.clamp(0, 5));
    return [...own, ...featured];
  }

  static List<CatalogAlbum> albumsOf(String artistId) {
    return albums.where((a) => a.artistId == artistId).toList();
  }

  static List<CatalogArtist> similarTo(String artistId) {
    final artist = artistById(artistId);
    final similar = artists
        .where((a) =>
            a.id != artistId && a.genres.any(artist.genres.contains))
        .toList();
    return similar.isEmpty
        ? artists.where((a) => a.id != artistId).take(4).toList()
        : similar;
  }

  /// Deterministic pseudo-random slice of the catalog used for mood, genre
  /// and category pages.
  static List<CatalogSong> songsForTag(String tag, {int count = 8}) {
    final seed = tag.codeUnits.fold<int>(0, (sum, c) => sum + c);
    final ordered = [...songs]
      ..sort((a, b) => ((a.id.hashCode ^ seed) % 97)
          .compareTo((b.id.hashCode ^ seed) % 97));
    return ordered.take(count).toList();
  }

  static CatalogSearchResult search(String query) {
    final q = normalize(query.trim());
    if (q.isEmpty) return const CatalogSearchResult();

    bool matches(String value) => normalize(value).contains(q);

    return CatalogSearchResult(
      songs: songs
          .where((s) => matches(s.title) || matches(s.artistName) || matches(s.albumTitle))
          .toList(),
      artists: artists.where((a) => matches(a.name)).toList(),
      albums: albums
          .where((a) => matches(a.title) || matches(a.artistName))
          .toList(),
      playlists: playlists
          .where((p) => matches(p.title) || matches(p.subtitle))
          .toList(),
    );
  }

  /// Lowercases and strips Vietnamese diacritics so "mua" matches "Mưa".
  static String normalize(String input) {
    const groups = {
      'a': 'àáạảãâầấậẩẫăằắặẳẵ',
      'e': 'èéẹẻẽêềếệểễ',
      'i': 'ìíịỉĩ',
      'o': 'òóọỏõôồốộổỗơờớợởỡ',
      'u': 'ùúụủũưừứựửữ',
      'y': 'ỳýỵỷỹ',
      'd': 'đ',
    };
    final buffer = StringBuffer();
    for (final rune in input.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      var replaced = char;
      for (final entry in groups.entries) {
        if (entry.value.contains(char)) {
          replaced = entry.key;
          break;
        }
      }
      buffer.write(replaced);
    }
    return buffer.toString();
  }
}
