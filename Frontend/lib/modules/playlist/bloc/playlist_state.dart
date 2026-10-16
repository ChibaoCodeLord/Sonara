import '../models/playlist_detail_model.dart';

class PlaylistState {
  final PlaylistDetailModel playlist;
  final bool isPlaying;
  final bool isSmartShuffle;
  final bool isDownloaded;
  final bool isFavorite;
  final String selectedMood; // 'default', 'peaceful', 'energetic', 'focus'

  const PlaylistState({
    required this.playlist,
    this.isPlaying = false,
    this.isSmartShuffle = false,
    this.isDownloaded = false,
    this.isFavorite = false,
    this.selectedMood = 'default',
  });

  PlaylistState copyWith({
    PlaylistDetailModel? playlist,
    bool? isPlaying,
    bool? isSmartShuffle,
    bool? isDownloaded,
    bool? isFavorite,
    String? selectedMood,
  }) {
    return PlaylistState(
      playlist: playlist ?? this.playlist,
      isPlaying: isPlaying ?? this.isPlaying,
      isSmartShuffle: isSmartShuffle ?? this.isSmartShuffle,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isFavorite: isFavorite ?? this.isFavorite,
      selectedMood: selectedMood ?? this.selectedMood,
    );
  }
}
