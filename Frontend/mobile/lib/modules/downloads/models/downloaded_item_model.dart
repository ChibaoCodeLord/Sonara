import '../../../core/catalog/catalog_models.dart';

class DownloadedItemModel {
  final CatalogSong song;
  final double sizeMb;
  final String quality; // 'FLAC', '320kbps'

  const DownloadedItemModel({
    required this.song,
    required this.sizeMb,
    required this.quality,
  });
}
