import '../../../core/catalog/catalog_models.dart';

class ArtistState {
  final CatalogArtist artist;
  final List<CatalogSong> topSongs;
  final List<CatalogAlbum> discography;
  final List<CatalogPlaylist> appearsOn;
  final List<CatalogArtist> similarArtists;
  final bool showAllTopSongs;
  final String discographyFilter; // 'all', 'album', 'single'

  const ArtistState({
    required this.artist,
    this.topSongs = const [],
    this.discography = const [],
    this.appearsOn = const [],
    this.similarArtists = const [],
    this.showAllTopSongs = false,
    this.discographyFilter = 'all',
  });

  List<CatalogSong> get visibleTopSongs =>
      showAllTopSongs ? topSongs : topSongs.take(5).toList();

  List<CatalogAlbum> get filteredDiscography {
    switch (discographyFilter) {
      case 'album':
        return discography.where((a) => a.type == 'Album').toList();
      case 'single':
        return discography.where((a) => a.type != 'Album').toList();
      default:
        return discography;
    }
  }

  ArtistState copyWith({bool? showAllTopSongs, String? discographyFilter}) {
    return ArtistState(
      artist: artist,
      topSongs: topSongs,
      discography: discography,
      appearsOn: appearsOn,
      similarArtists: similarArtists,
      showAllTopSongs: showAllTopSongs ?? this.showAllTopSongs,
      discographyFilter: discographyFilter ?? this.discographyFilter,
    );
  }
}
