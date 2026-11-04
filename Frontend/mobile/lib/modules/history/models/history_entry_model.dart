import '../../../core/catalog/catalog_models.dart';

class ListeningHistoryEntry {
  final String id;
  final CatalogSong song;
  final DateTime playedAt;
  final String source; // 'Playlist', 'AI Hum', 'Tìm kiếm'...

  const ListeningHistoryEntry({
    required this.id,
    required this.song,
    required this.playedAt,
    required this.source,
  });
}

class HumHistoryEntry {
  final String id;
  final CatalogSong song;
  final DateTime recordedAt;
  final int matchPercentage;
  final String mode; // 'hum' | 'whistle'
  final int recordSeconds;

  const HumHistoryEntry({
    required this.id,
    required this.song,
    required this.recordedAt,
    required this.matchPercentage,
    required this.mode,
    required this.recordSeconds,
  });

  String get modeLabel => mode == 'whistle' ? 'Huýt sáo' : 'Ngân nga';
}
