import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/playing_song_model.dart';
import '../services/player_service.dart';
import 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final PlayerService _service;

  PlayerCubit({PlayerService? service})
      : _service = service ?? PlayerService(),
        super(PlayerState(
          song: (service ?? PlayerService()).getDefaultPlayingSong(),
          lyrics: (service ?? PlayerService()).getLyricsForSong('song_bau_troi_moi'),
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

  void playNext() {
    // Demo progression
    seek(0);
    emit(state.copyWith(isPlaying: true));
  }

  void playPrevious() {
    seek(0);
    emit(state.copyWith(isPlaying: true));
  }
}
