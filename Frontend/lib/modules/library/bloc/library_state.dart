import '../models/following_artist_model.dart';
import '../models/library_playlist_model.dart';
import '../models/recent_hum_history_model.dart';

class LibraryState {
  final String selectedFilter; // 'all', 'playlist', 'liked', 'ai-hum', 'artists'
  final List<FollowingArtistModel> artists;
  final List<LibraryPlaylistModel> playlists;
  final RecentHumHistoryModel recentHum;
  final int likedSongsCount;
  final int humHistoryCount;
  final String storageUsedText;

  const LibraryState({
    this.selectedFilter = 'all',
    this.artists = const [],
    this.playlists = const [],
    required this.recentHum,
    this.likedSongsCount = 328,
    this.humHistoryCount = 14,
    this.storageUsedText = '4.2 GB • Chất lượng Studio Master',
  });

  LibraryState copyWith({
    String? selectedFilter,
    List<FollowingArtistModel>? artists,
    List<LibraryPlaylistModel>? playlists,
    RecentHumHistoryModel? recentHum,
    int? likedSongsCount,
    int? humHistoryCount,
    String? storageUsedText,
  }) {
    return LibraryState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      artists: artists ?? this.artists,
      playlists: playlists ?? this.playlists,
      recentHum: recentHum ?? this.recentHum,
      likedSongsCount: likedSongsCount ?? this.likedSongsCount,
      humHistoryCount: humHistoryCount ?? this.humHistoryCount,
      storageUsedText: storageUsedText ?? this.storageUsedText,
    );
  }
}
