import '../../../core/catalog/catalog_models.dart';

class RecapGenreShare {
  final String genre;
  final double share; // 0..1

  const RecapGenreShare(this.genre, this.share);
}

class RecapModel {
  final int year;
  final int totalMinutes;
  final String topPercentText;
  final List<CatalogSong> topSongs;
  final List<CatalogArtist> topArtists;
  final List<RecapGenreShare> genres;
  final String personalityTitle;
  final String personalityDescription;
  final int humCount;
  final CatalogSong mostHummed;

  const RecapModel({
    required this.year,
    required this.totalMinutes,
    required this.topPercentText,
    required this.topSongs,
    required this.topArtists,
    required this.genres,
    required this.personalityTitle,
    required this.personalityDescription,
    required this.humCount,
    required this.mostHummed,
  });
}
