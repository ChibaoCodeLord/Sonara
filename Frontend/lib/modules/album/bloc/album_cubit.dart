import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/album_mock_service.dart';
import 'album_state.dart';

class AlbumCubit extends Cubit<AlbumState> {
  Timer? _downloadTimer;

  AlbumCubit({required String albumId, AlbumMockService? service})
      : super(_load(albumId, service ?? AlbumMockService()));

  static AlbumState _load(String id, AlbumMockService service) {
    final album = service.getAlbum(id);
    return AlbumState(
      album: album,
      tracks: service.getTracks(id),
      moreAlbums: service.getMoreFromArtist(album),
    );
  }

  void toggleSaved() {
    emit(state.copyWith(isSaved: !state.isSaved));
  }

  /// Simulates downloading the whole album for offline listening.
  void toggleDownload() {
    if (state.isDownloaded || state.isDownloading) {
      _downloadTimer?.cancel();
      emit(state.copyWith(isDownloaded: false, downloadProgress: 0));
      return;
    }
    emit(state.copyWith(downloadProgress: 0.05));
    _downloadTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      final next = state.downloadProgress + 0.05;
      if (next >= 1) {
        timer.cancel();
        emit(state.copyWith(isDownloaded: true, downloadProgress: 0));
      } else {
        emit(state.copyWith(downloadProgress: next));
      }
    });
  }

  @override
  Future<void> close() {
    _downloadTimer?.cancel();
    return super.close();
  }
}
