import '../models/lyric_line_model.dart';
import '../models/playing_song_model.dart';

class PlayerState {
  final PlayingSongModel song;
  final bool isPlaying;
  final bool isShuffle;
  final bool isRepeat;
  final bool isSpatialActive;
  final String audioRouteDevice;
  final List<LyricLineModel> lyrics;

  const PlayerState({
    required this.song,
    this.isPlaying = true,
    this.isShuffle = true,
    this.isRepeat = false,
    this.isSpatialActive = true,
    this.audioRouteDevice = 'AirPods Pro',
    this.lyrics = const [],
  });

  PlayerState copyWith({
    PlayingSongModel? song,
    bool? isPlaying,
    bool? isShuffle,
    bool? isRepeat,
    bool? isSpatialActive,
    String? audioRouteDevice,
    List<LyricLineModel>? lyrics,
  }) {
    return PlayerState(
      song: song ?? this.song,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffle: isShuffle ?? this.isShuffle,
      isRepeat: isRepeat ?? this.isRepeat,
      isSpatialActive: isSpatialActive ?? this.isSpatialActive,
      audioRouteDevice: audioRouteDevice ?? this.audioRouteDevice,
      lyrics: lyrics ?? this.lyrics,
    );
  }
}
