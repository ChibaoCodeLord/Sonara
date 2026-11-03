import 'package:flutter_bloc/flutter_bloc.dart';
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
    final allPlaylists = _service.getPlaylists();
    emit(state.copyWith(
      selectedFilter: filterKey,
      playlists: allPlaylists,
    ));
  }
}
