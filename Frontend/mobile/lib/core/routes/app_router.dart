import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../modules/app/presentations/main_shell_screen.dart';
import '../../modules/hum_to_search/bloc/hum_search_cubit.dart';
import '../../modules/hum_to_search/presentations/hum_to_search_screen.dart';
import '../../modules/hum_to_search/presentations/hum_search_result_screen.dart';
import '../../modules/player/presentations/now_playing_screen.dart';
import '../../modules/playlist/presentations/playlist_detail_screen.dart';

class AppRouter {
  AppRouter._();

  static const String shell = '/';
  static const String humToSearch = '/hum-to-search';
  static const String humSearchResult = '/hum-search-result';
  static const String nowPlaying = '/now-playing';
  static const String playlistDetail = '/playlist-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case shell:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
      case humToSearch:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => HumSearchCubit(),
            child: const HumToSearchScreen(),
          ),
        );
      case humSearchResult:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => HumSearchCubit(),
            child: const HumSearchResultScreen(),
          ),
        );
      case nowPlaying:
        return MaterialPageRoute(builder: (_) => const NowPlayingScreen());
      case playlistDetail:
        final playlistId = (settings.arguments as String?) ?? 'ai_curated_01';
        return MaterialPageRoute(
          builder: (_) => PlaylistDetailScreen(playlistId: playlistId),
        );
      default:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
    }
  }
}
