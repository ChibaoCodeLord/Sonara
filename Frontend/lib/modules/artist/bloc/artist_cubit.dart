import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/artist_mock_service.dart';
import 'artist_state.dart';

class ArtistCubit extends Cubit<ArtistState> {
  ArtistCubit({required String artistId, ArtistMockService? service})
    : super(_load(artistId, service ?? ArtistMockService()));

  static ArtistState _load(String id, ArtistMockService service) {
    return ArtistState(
      artist: service.getArtist(id),
      topSongs: service.getTopSongs(id),
      discography: service.getDiscography(id),
      appearsOn: service.getAppearsOn(id),
      similarArtists: service.getSimilarArtists(id),
    );
  }

  void toggleShowAllTopSongs() {
    emit(state.copyWith(showAllTopSongs: !state.showAllTopSongs));
  }

  void setDiscographyFilter(String filter) {
    emit(state.copyWith(discographyFilter: filter));
  }
}
