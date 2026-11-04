import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/following_artist_model.dart';
import '../models/library_playlist_model.dart';
import '../services/library_mock_service.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final LibraryMockService _service;

  LibraryCubit({LibraryMockService? service})
      : _service = service ?? LibraryMockService(),
        super(LibraryState(
          recentHum: (service ?? LibraryMockService()).getRecentHumMatch(),
          artists: (service ?? LibraryMockService()).getFollowingArtists(),
          playlists: (service ?? LibraryMockService()).getPlaylists(),
        ));

  void selectFilter(String filterKey) {
    emit(state.copyWith(selectedFilter: filterKey));
  }

  /// Creates a user playlist and returns it so callers can add a song.
  LibraryPlaylistModel createPlaylist({
    required String title,
    String description = '',
    String? coverUrl,
    bool isPublic = true,
    bool isCollaborative = false,
    int trackCount = 0,
  }) {
    final playlist = LibraryPlaylistModel(
      id: 'user_playlist_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      creator: 'Tự tạo bởi bạn',
      trackCount: trackCount,
      coverUrl: coverUrl ?? _service.defaultPlaylistCover,
      badgeType: 'user_created',
      badgeLabel: isCollaborative ? 'Cộng tác' : 'Cá nhân',
      description: description,
      isPublic: isPublic,
      isCollaborative: isCollaborative,
    );
    emit(state.copyWith(playlists: [playlist, ...state.playlists]));
    return playlist;
  }

  void updatePlaylist(LibraryPlaylistModel updated) {
    emit(state.copyWith(
      playlists: [
        for (final p in state.playlists) p.id == updated.id ? updated : p,
      ],
    ));
  }

  void deletePlaylist(String playlistId) {
    emit(state.copyWith(
      playlists: state.playlists.where((p) => p.id != playlistId).toList(),
    ));
  }

  void addSongToPlaylist(String playlistId) {
    emit(state.copyWith(
      playlists: [
        for (final p in state.playlists)
          p.id == playlistId ? p.copyWith(trackCount: p.trackCount + 1) : p,
      ],
    ));
  }

  bool isFollowing(String artistId) =>
      state.artists.any((artist) => artist.id == artistId);

  void toggleFollowArtist(FollowingArtistModel artist) {
    if (isFollowing(artist.id)) {
      emit(state.copyWith(
        artists: state.artists.where((a) => a.id != artist.id).toList(),
      ));
    } else {
      emit(state.copyWith(artists: [...state.artists, artist]));
    }
  }
}
