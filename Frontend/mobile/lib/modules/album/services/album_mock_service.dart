import '../../../core/catalog/catalog_models.dart';
import '../../../core/catalog/music_catalog.dart';

class AlbumMockService {
  CatalogAlbum getAlbum(String id) => MusicCatalog.albumById(id);

  List<CatalogSong> getTracks(String id) => MusicCatalog.songsOfAlbum(id);

  List<CatalogAlbum> getMoreFromArtist(CatalogAlbum album) {
    final others = MusicCatalog.albumsOf(album.artistId)
        .where((a) => a.id != album.id)
        .toList();
    if (others.isNotEmpty) return others;
    return MusicCatalog.albums.where((a) => a.id != album.id).take(4).toList();
  }
}
