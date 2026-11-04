import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/playing_song_model.dart';
import '../services/player_service.dart';
import 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final PlayerService _service;
  Timer? _sleepTimer;

  PlayerCubit({PlayerService? service})
      : _service = service ?? PlayerService(),
        super(PlayerState(
          song: (service ?? PlayerService()).getDefaultPlayingSong(),
          lyrics: (service ?? PlayerService()).getLyricsForSong('song_bau_troi_moi'),
          queue: (service ?? PlayerService()).getDefaultQueue(),
        ));

  void togglePlayPause() {
    emit(state.copyWith(isPlaying: !state.isPlaying));
  }

  void play() {
    emit(state.copyWith(isPlaying: true));
  }

  void pause() {
    emit(state.copyWith(isPlaying: false));
  }

  void toggleFavorite() {
    final updatedSong = state.song.copyWith(
      isFavorite: !state.song.isFavorite,
    );
    emit(state.copyWith(song: updatedSong));
  }

  void toggleShuffle() {
    emit(state.copyWith(isShuffle: !state.isShuffle));
  }

  void toggleRepeat() {
    emit(state.copyWith(isRepeat: !state.isRepeat));
  }

  void toggleSpatialAudio() {
    emit(state.copyWith(isSpatialActive: !state.isSpatialActive));
  }

  void toggleKaraokeMode() {
    emit(state.copyWith(isKaraokeMode: !state.isKaraokeMode));
  }

  void setAudioRoute(String device) {
    emit(state.copyWith(audioRouteDevice: device));
  }

  void seek(int seconds) {
    final clamped = seconds.clamp(0, state.song.durationSeconds);
    final updatedSong = state.song.copyWith(currentSeconds: clamped);
    emit(state.copyWith(song: updatedSong));
  }

  void playSong(PlayingSongModel song) {
    final lyrics = _service.getLyricsForSong(song.id);
    emit(state.copyWith(
      song: song,
      isPlaying: true,
      lyrics: lyrics,
    ));
  }

  /// Plays [songs] in order: the first starts now, the rest replace the queue.
  void playAll(List<PlayingSongModel> songs) {
    if (songs.isEmpty) return;
    playSong(songs.first);
    emit(state.copyWith(queue: songs.skip(1).toList()));
  }

  void playNext() {
    if (state.sleepAfterCurrentTrack) {
      cancelSleepTimer();
      seek(0);
      emit(state.copyWith(isPlaying: false));
      return;
    }
    if (state.queue.isNotEmpty) {
      final next = state.queue.first;
      emit(state.copyWith(queue: state.queue.sublist(1)));
      playSong(next.copyWith(currentSeconds: 0));
      return;
    }
    // Demo progression
    seek(0);
    emit(state.copyWith(isPlaying: true));
  }

  void playPrevious() {
    seek(0);
    emit(state.copyWith(isPlaying: true));
  }

  // Queue (Up Next)

  void addToQueue(PlayingSongModel song) {
    emit(state.copyWith(queue: [...state.queue, song]));
  }

  void playAfterCurrent(PlayingSongModel song) {
    emit(state.copyWith(queue: [song, ...state.queue]));
  }

  void removeFromQueue(int index) {
    final queue = [...state.queue]..removeAt(index);
    emit(state.copyWith(queue: queue));
  }

  /// [newIndex] is the final position after [oldIndex] has been removed.
  void reorderQueue(int oldIndex, int newIndex) {
    final queue = [...state.queue];
    final item = queue.removeAt(oldIndex);
    queue.insert(newIndex, item);
    emit(state.copyWith(queue: queue));
  }

  void playFromQueue(int index) {
    final song = state.queue[index];
    emit(state.copyWith(queue: state.queue.sublist(index + 1)));
    playSong(song.copyWith(currentSeconds: 0));
  }

  void clearQueue() {
    emit(state.copyWith(queue: const []));
  }

  void toggleAutoplay() {
    emit(state.copyWith(isAutoplay: !state.isAutoplay));
  }

  // Sleep timer

  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    emit(state.copyWith(clearSleepTimer: true));
    emit(state.copyWith(sleepRemaining: duration));
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.sleepRemaining;
      if (remaining == null) return;
      final next = remaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        _sleepTimer?.cancel();
        emit(state.copyWith(isPlaying: false, clearSleepTimer: true));
      } else {
        emit(state.copyWith(sleepRemaining: next));
      }
    });
  }

  void sleepAfterCurrentTrack() {
    _sleepTimer?.cancel();
    emit(state.copyWith(clearSleepTimer: true));
    emit(state.copyWith(sleepAfterCurrentTrack: true));
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    emit(state.copyWith(clearSleepTimer: true));
  }


  @override
  Future<void> close() {
    _sleepTimer?.cancel();
    return super.close();
  }
}
