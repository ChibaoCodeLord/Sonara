import '../../../core/catalog/music_catalog.dart';

class SearchMockService {
  // Kept in RAM so recent searches survive leaving and re-opening Search.
  static final List<String> _recentSearches = [
    'Bầu Trời Mới',
    'Vũ.',
    'lo-fi chill',
    'Hoàng Dũng',
  ];

  static const int maxRecent = 10;

  List<String> getRecentSearches() => List.unmodifiable(_recentSearches);

  void addRecentSearch(String query) {
    _recentSearches
      ..removeWhere((q) => q.toLowerCase() == query.toLowerCase())
      ..insert(0, query);
    if (_recentSearches.length > maxRecent) _recentSearches.removeLast();
  }

  void removeRecentSearch(String query) => _recentSearches.remove(query);

  void clearRecentSearches() => _recentSearches.clear();

  List<String> getTrendingKeywords() => const [
        'Khóa Ánh Mắt Lại',
        'Sơn Tùng M-TP',
        'nhạc cafe acoustic',
        'Espresso',
        'Rap Việt',
      ];

  CatalogSearchResult search(String query) => MusicCatalog.search(query);
}
