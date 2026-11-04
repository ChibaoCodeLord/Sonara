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
  final List<PlayingSongModel> queue;
  final bool isAutoplay;
  final bool isKaraokeMode;
  final Duration? sleepRemaining;
  final bool sleepAfterCurrentTrack;

  const PlayerState({
    required this.song,
    this.isPlaying = true,
    this.isShuffle = true,
    this.isRepeat = false,
    this.isSpatialActive = true,
    this.audioRouteDevice = 'AirPods Pro',
    this.lyrics = const [],
    this.queue = const [],
    this.isAutoplay = true,
    this.isKaraokeMode = false,
    this.sleepRemaining,
    this.sleepAfterCurrentTrack = false,
  });

  bool get hasSleepTimer => sleepRemaining != null || sleepAfterCurrentTrack;

  PlayerState copyWith({
    PlayingSongModel? song,
    bool? isPlaying,
    bool? isShuffle,
    bool? isRepeat,
    bool? isSpatialActive,
    String? audioRouteDevice,
    List<LyricLineModel>? lyrics,
    List<PlayingSongModel>? queue,
    bool? isAutoplay,
    bool? isKaraokeMode,
    Duration? sleepRemaining,
    bool? sleepAfterCurrentTrack,
    bool clearSleepTimer = false,
  }) {
    return PlayerState(
      song: song ?? this.song,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffle: isShuffle ?? this.isShuffle,
      isRepeat: isRepeat ?? this.isRepeat,
      isSpatialActive: isSpatialActive ?? this.isSpatialActive,
      audioRouteDevice: audioRouteDevice ?? this.audioRouteDevice,
      lyrics: lyrics ?? this.lyrics,
      queue: queue ?? this.queue,
      isAutoplay: isAutoplay ?? this.isAutoplay,
      isKaraokeMode: isKaraokeMode ?? this.isKaraokeMode,
      sleepRemaining:
          clearSleepTimer ? null : (sleepRemaining ?? this.sleepRemaining),
      sleepAfterCurrentTrack: clearSleepTimer
          ? false
          : (sleepAfterCurrentTrack ?? this.sleepAfterCurrentTrack),
    );
  }
}
