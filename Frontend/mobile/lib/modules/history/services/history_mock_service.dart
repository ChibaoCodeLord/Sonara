import '../../../core/catalog/music_catalog.dart';
import '../models/history_entry_model.dart';

class HistoryMockService {
  List<ListeningHistoryEntry> getListeningHistory() {
    final now = DateTime.now();
    const sources = ['Sonara AI Mix', 'AI Hum Match', 'Tìm kiếm', 'Bảng xếp hạng'];
    // (song index, hours ago)
    const plan = [
      (0, 0.3), (3, 1.2), (6, 2.5), (12, 4.0),
      (9, 26.0), (10, 28.5), (14, 31.0),
      (4, 52.0), (11, 75.0), (15, 98.0), (7, 120.0), (13, 160.0),
    ];
    final songs = MusicCatalog.songs;
    return [
      for (var i = 0; i < plan.length; i++)
        ListeningHistoryEntry(
          id: 'history_$i',
          song: songs[plan[i].$1 % songs.length],
          playedAt: now.subtract(
            Duration(minutes: (plan[i].$2 * 60).round()),
          ),
          source: sources[i % sources.length],
        ),
    ];
  }

  List<HumHistoryEntry> getHumHistory() {
    final now = DateTime.now();
    // (song index, hours ago, match %, mode)
    const plan = [
      (4, 2.0, 98, 'hum'),
      (0, 5.0, 96, 'whistle'),
      (13, 22.0, 91, 'hum'),
      (6, 30.0, 88, 'hum'),
      (14, 49.0, 94, 'whistle'),
      (9, 70.0, 84, 'hum'),
      (11, 96.0, 79, 'whistle'),
      (15, 130.0, 97, 'hum'),
    ];
    final songs = MusicCatalog.songs;
    return [
      for (var i = 0; i < plan.length; i++)
        HumHistoryEntry(
          id: 'hum_$i',
          song: songs[plan[i].$1 % songs.length],
          recordedAt: now.subtract(Duration(minutes: (plan[i].$2 * 60).round())),
          matchPercentage: plan[i].$3,
          mode: plan[i].$4,
          recordSeconds: 7 + i % 8,
        ),
    ];
  }
}
