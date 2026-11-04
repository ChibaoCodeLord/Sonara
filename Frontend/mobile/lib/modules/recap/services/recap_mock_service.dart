import '../../../core/catalog/music_catalog.dart';
import '../models/recap_model.dart';

class RecapMockService {
  RecapModel getRecap() {
    final songs = MusicCatalog.songs;
    return RecapModel(
      year: DateTime.now().year,
      totalMinutes: 28800,
      topPercentText: 'Top 2% thính giả Indie Việt',
      topSongs: [songs[4], songs[0], songs[6], songs[14], songs[11]],
      topArtists: [
        MusicCatalog.artistById('artist_vu'),
        MusicCatalog.artistById('artist_dalab'),
        MusicCatalog.artistById('artist_hoangdung'),
      ],
      genres: const [
        RecapGenreShare('Indie', 0.38),
        RecapGenreShare('Ballad', 0.27),
        RecapGenreShare('Lo-fi', 0.19),
        RecapGenreShare('V-Pop', 0.16),
      ],
      personalityTitle: 'Kẻ Mộng Mơ Lúc Nửa Đêm',
      personalityDescription:
          'Sonara AI nhận thấy bạn nghe nhiều nhất từ 22h-1h, ưu tiên giai điệu chậm, ca từ tự sự và âm sắc mộc.',
      humCount: 142,
      mostHummed: songs[0],
    );
  }
}
