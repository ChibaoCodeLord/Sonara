import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/catalog/music_catalog.dart';
import '../services/search_mock_service.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  static const Duration debounce = Duration(milliseconds: 300);

  final SearchMockService _service;
  Timer? _debounceTimer;

  SearchCubit({SearchMockService? service, String initialQuery = ''})
      : _service = service ?? SearchMockService(),
        super(SearchState(
          recentSearches: (service ?? SearchMockService()).getRecentSearches(),
          trendingKeywords:
              (service ?? SearchMockService()).getTrendingKeywords(),
        )) {
    if (initialQuery.isNotEmpty) submit(initialQuery);
  }

  /// Live search while typing, debounced by 300ms.
  void onQueryChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      emit(state.copyWith(
        query: '',
        isSearching: false,
        results: const CatalogSearchResult(),
      ));
      return;
    }
    emit(state.copyWith(query: query, isSearching: true));
    _debounceTimer = Timer(debounce, () {
      emit(state.copyWith(
        isSearching: false,
        results: _service.search(query),
      ));
    });
  }

  /// Runs the search immediately and records it in recent searches.
  void submit(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _debounceTimer?.cancel();
    _service.addRecentSearch(trimmed);
    emit(state.copyWith(
      query: trimmed,
      isSearching: false,
      results: _service.search(trimmed),
      recentSearches: _service.getRecentSearches(),
    ));
  }

  void removeRecent(String query) {
    _service.removeRecentSearch(query);
    emit(state.copyWith(recentSearches: _service.getRecentSearches()));
  }

  void clearRecent() {
    _service.clearRecentSearches();
    emit(state.copyWith(recentSearches: const []));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
