import '../../../core/catalog/catalog_models.dart';
import '../../../core/catalog/music_catalog.dart';

class ArtistMockService {
  CatalogArtist getArtist(String id) => MusicCatalog.artistById(id);

  List<CatalogSong> getTopSongs(String id) {
    final own = MusicCatalog.topSongsOf(id);
    // Top list shows up to 10: own songs first, then collaborations.
    final extra = MusicCatalog.songsForTag(
      id,
      count: 10,
    ).where((s) => !own.contains(s));
    return [...own, ...extra].take(10).toList();
  }

  List<CatalogAlbum> getDiscography(String id) => MusicCatalog.albumsOf(id);

  List<CatalogPlaylist> getAppearsOn(String id) {
    final playlists = [...MusicCatalog.playlists]
      ..sort(
        (a, b) => (a.id.hashCode ^ id.hashCode).compareTo(
          b.id.hashCode ^ id.hashCode,
        ),
      );
    return playlists.take(4).toList();
  }

  List<CatalogArtist> getSimilarArtists(String id) =>
      MusicCatalog.similarTo(id);
}
