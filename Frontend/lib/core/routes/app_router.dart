import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../modules/album/presentations/album_detail_screen.dart';
import '../../modules/app/presentations/main_shell_screen.dart';
import '../../modules/artist/presentations/artist_detail_screen.dart';
import '../../modules/auth/presentations/otp_verification_screen.dart';
import '../../modules/auth/presentations/sign_in_screen.dart';
import '../../modules/auth/presentations/sign_up_screen.dart';
import '../../modules/auth/presentations/taste_picker_screen.dart';
import '../../modules/auth/presentations/welcome_screen.dart';
import '../../modules/charts/presentations/full_chart_screen.dart';
import '../../modules/downloads/presentations/offline_music_screen.dart';
import '../../modules/equalizer/presentations/equalizer_screen.dart';
import '../../modules/history/presentations/hum_history_screen.dart';
import '../../modules/history/presentations/listening_history_screen.dart';
import '../../modules/home/presentations/all_mixes_screen.dart';
import '../../modules/hum_to_search/bloc/hum_search_cubit.dart';
import '../../modules/hum_to_search/presentations/hum_search_result_screen.dart';
import '../../modules/hum_to_search/presentations/hum_to_search_screen.dart';
import '../../modules/library/presentations/following_artists_screen.dart';
import '../../modules/player/presentations/lyrics_screen.dart';
import '../../modules/player/presentations/now_playing_screen.dart';
import '../../modules/playlist/presentations/playlist_detail_screen.dart';
import '../../modules/premium/presentations/premium_screen.dart';
import '../../modules/profile/presentations/edit_profile_screen.dart';
import '../../modules/recap/presentations/recap_screen.dart';
import '../../modules/search/presentations/category_detail_screen.dart';
import '../../modules/search/presentations/search_results_screen.dart';
import '../../modules/search/presentations/search_screen.dart';
import '../../modules/settings/presentations/settings_screen.dart';
import '../../modules/wave_code/presentations/wave_code_scanner_screen.dart';
import '../catalog/catalog_models.dart';
import '../catalog/music_catalog.dart';

class AppRouter {
  AppRouter._();

  static const String shell = '/';
  static const String humToSearch = '/hum-to-search';
  static const String humSearchResult = '/hum-search-result';
  static const String nowPlaying = '/now-playing';
  static const String playlistDetail = '/playlist-detail';

  // Authentication & Onboarding
  static const String welcome = '/welcome';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String otpVerification = '/otp-verification';
  static const String tastePicker = '/taste-picker';

  // Search & Browse
  static const String search = '/search';
  static const String searchResults = '/search-results';
  static const String categoryDetail = '/category-detail';

  // Music entities
  static const String artistDetail = '/artist-detail';
  static const String albumDetail = '/album-detail';
  static const String followingArtists = '/following-artists';
  static const String allMixes = '/all-mixes';
  static const String fullChart = '/full-chart';

  // Player extensions
  static const String lyrics = '/lyrics';
  static const String equalizer = '/equalizer';

  // Offline & History
  static const String offlineMusic = '/offline-music';
  static const String listeningHistory = '/listening-history';
  static const String humHistory = '/hum-history';

  // Monetization, Settings & Account
  static const String premium = '/premium';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';

  // Viral & Community
  static const String recap = '/recap';
  static const String waveCodeScanner = '/wave-code-scanner';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    Route<dynamic> page(Widget child) =>
        MaterialPageRoute(settings: settings, builder: (_) => child);

    switch (settings.name) {
      case shell:
        return page(const MainShellScreen());
      case humToSearch:
        return page(
          BlocProvider(
            create: (_) => HumSearchCubit(),
            child: const HumToSearchScreen(),
          ),
        );
      case humSearchResult:
        return page(const HumSearchResultScreen());
      case nowPlaying:
        return page(const NowPlayingScreen());
      case playlistDetail:
        return page(
          PlaylistDetailScreen(playlistId: (args as String?) ?? 'ai_curated_01'),
        );

      // Authentication & Onboarding
      case welcome:
        return page(const WelcomeScreen());
      case signIn:
        return page(const SignInScreen());
      case signUp:
        return page(const SignUpScreen());
      case otpVerification:
        return page(const OtpVerificationScreen());
      case tastePicker:
        return page(TastePickerScreen(isOnboarding: (args as bool?) ?? true));

      // Search & Browse
      case search:
        return page(SearchScreen(initialQuery: args as String?));
      case searchResults:
        return page(SearchResultsScreen(query: (args as String?) ?? ''));
      case categoryDetail:
        return page(
          CategoryDetailScreen(
            category: (args as CatalogCategory?) ??
                MusicCatalog.browseCategories.first,
          ),
        );

      // Music entities
      case artistDetail:
        return page(
          ArtistDetailScreen(
            artistId: (args as String?) ?? MusicCatalog.artists.first.id,
          ),
        );
      case albumDetail:
        return page(
          AlbumDetailScreen(
            albumId: (args as String?) ?? MusicCatalog.albums.first.id,
          ),
        );
      case followingArtists:
        return page(const FollowingArtistsScreen());
      case allMixes:
        return page(const AllMixesScreen());
      case fullChart:
        return page(FullChartScreen(initialTab: (args as String?) ?? 'vn'));

      // Player extensions
      case lyrics:
        return MaterialPageRoute(
          settings: settings,
          fullscreenDialog: true,
          builder: (_) => const LyricsScreen(),
        );
      case equalizer:
        return page(const EqualizerScreen());

      // Offline & History
      case offlineMusic:
        return page(const OfflineMusicScreen());
      case listeningHistory:
        return page(const ListeningHistoryScreen());
      case humHistory:
        return page(const HumHistoryScreen());

      // Monetization, Settings & Account
      case premium:
        return MaterialPageRoute(
          settings: settings,
          fullscreenDialog: true,
          builder: (_) => const PremiumScreen(),
        );
      case AppRouter.settings:
        return page(const SettingsScreen());
      case editProfile:
        return page(const EditProfileScreen());

      // Viral & Community
      case recap:
        return MaterialPageRoute(
          settings: settings,
          fullscreenDialog: true,
          builder: (_) => const RecapScreen(),
        );
      case waveCodeScanner:
        return MaterialPageRoute(
          settings: settings,
          fullscreenDialog: true,
          builder: (_) => const WaveCodeScannerScreen(),
        );

      default:
        return page(const MainShellScreen());
    }
  }
}
