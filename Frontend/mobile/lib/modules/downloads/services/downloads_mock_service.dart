import '../../../core/catalog/music_catalog.dart';
import '../models/downloaded_item_model.dart';

class DownloadsMockService {
  static const double deviceTotalGb = 128;
  static const double otherAppsGb = 71.4;

  List<DownloadedItemModel> getDownloads() {
    return [
      for (var i = 0; i < MusicCatalog.songs.length; i += 2)
        DownloadedItemModel(
          song: MusicCatalog.songs[i],
          // FLAC ≈ 1.4 MB per 10s of audio at 24-bit, 320kbps ≈ 0.4 MB.
          sizeMb: i % 3 == 0
              ? MusicCatalog.songs[i].durationSeconds * 0.04
              : MusicCatalog.songs[i].durationSeconds * 0.14,
          quality: i % 3 == 0 ? '320kbps' : 'FLAC',
        ),
    ];
  }

  double getCacheMb() => 812;
}
