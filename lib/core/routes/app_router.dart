import 'package:flutter/material.dart';
import '../../modules/app/presentations/main_shell_screen.dart';
import '../../modules/hum_to_search/presentations/hum_to_search_screen.dart';
import '../../modules/hum_to_search/presentations/hum_search_result_screen.dart';
import '../../modules/player/presentations/now_playing_screen.dart';

class AppRouter {
  AppRouter._();

  static const String shell = '/';
  static const String humToSearch = '/hum-to-search';
  static const String humSearchResult = '/hum-search-result';
  static const String nowPlaying = '/now-playing';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case shell:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
      case humToSearch:
        return MaterialPageRoute(builder: (_) => const HumToSearchScreen());
      case humSearchResult:
        return MaterialPageRoute(builder: (_) => const HumSearchResultScreen());
      case nowPlaying:
        return MaterialPageRoute(builder: (_) => const NowPlayingScreen());
      default:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
    }
  }
}
