import '../models/downloaded_item_model.dart';

class DownloadsState {
  final List<DownloadedItemModel> items;
  final double cacheMb;
  final String downloadQuality; // 'FLAC', '320kbps'
  final bool wifiOnly;
  final bool autoDownloadLiked;

  const DownloadsState({
    this.items = const [],
    this.cacheMb = 0,
    this.downloadQuality = 'FLAC',
    this.wifiOnly = true,
    this.autoDownloadLiked = false,
  });

  double get downloadsMb => items.fold(0, (sum, item) => sum + item.sizeMb);

  DownloadsState copyWith({
    List<DownloadedItemModel>? items,
    double? cacheMb,
    String? downloadQuality,
    bool? wifiOnly,
    bool? autoDownloadLiked,
  }) {
    return DownloadsState(
      items: items ?? this.items,
      cacheMb: cacheMb ?? this.cacheMb,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      autoDownloadLiked: autoDownloadLiked ?? this.autoDownloadLiked,
    );
  }
}
