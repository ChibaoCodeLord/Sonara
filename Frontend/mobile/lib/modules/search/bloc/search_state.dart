import '../../../core/catalog/music_catalog.dart';

class SearchState {
  final String query;
  final bool isSearching;
  final CatalogSearchResult results;
  final List<String> recentSearches;
  final List<String> trendingKeywords;

  const SearchState({
    this.query = '',
    this.isSearching = false,
    this.results = const CatalogSearchResult(),
    this.recentSearches = const [],
    this.trendingKeywords = const [],
  });

  SearchState copyWith({
    String? query,
    bool? isSearching,
    CatalogSearchResult? results,
    List<String>? recentSearches,
    List<String>? trendingKeywords,
  }) {
    return SearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      trendingKeywords: trendingKeywords ?? this.trendingKeywords,
    );
  }
}
