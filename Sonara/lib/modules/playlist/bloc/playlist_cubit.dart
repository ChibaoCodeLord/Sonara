import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/playlist_mock_service.dart';
import 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  final PlaylistMockService _service;

  PlaylistCubit({String playlistId = 'ai_curated_01', PlaylistMockService? service})
      : _service = service ?? PlaylistMockService(),
        super(PlaylistState(
          playlist: (service ?? PlaylistMockService()).getPlaylistDetail(playlistId),
        ));

  void togglePlay() {
    emit(state.copyWith(isPlaying: !state.isPlaying));
  }

  void toggleSmartShuffle() {
    emit(state.copyWith(isSmartShuffle: !state.isSmartShuffle));
  }

  void toggleDownload() {
    emit(state.copyWith(isDownloaded: !state.isDownloaded));
  }

  void toggleFavorite() {
    emit(state.copyWith(isFavorite: !state.isFavorite));
  }

  void selectMood(String mood) {
    emit(state.copyWith(selectedMood: mood));
  }

  void loadPlaylist(String id) {
    final detail = _service.getPlaylistDetail(id);
    emit(state.copyWith(playlist: detail));
  }
}
