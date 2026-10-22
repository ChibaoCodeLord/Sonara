import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../modules/player/bloc/player_cubit.dart';
import '../../modules/player/models/playing_song_model.dart';
import '../../modules/player/presentations/now_playing_screen.dart';
import '../catalog/music_catalog.dart';
import 'app_router.dart';

/// Navigation shortcuts shared by every module so screens don't need to know
/// how other features are constructed.
class AppNavigator {
  AppNavigator._();

  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  static void openNowPlaying(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NowPlayingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  static void playAndOpen(BuildContext context, PlayingSongModel song) {
    context.read<PlayerCubit>().playSong(song);
    openNowPlaying(context);
  }

  static void openHumSearch(BuildContext context) =>
      push(context, AppRouter.humToSearch);

  static void openSearch(BuildContext context, {String? query}) =>
      push(context, AppRouter.search, arguments: query);

  static void openPlaylist(BuildContext context, String playlistId) =>
      push(context, AppRouter.playlistDetail, arguments: playlistId);

  static void openArtist(BuildContext context, String artistId) =>
      push(context, AppRouter.artistDetail, arguments: artistId);

  static void openAlbum(BuildContext context, String albumId) =>
      push(context, AppRouter.albumDetail, arguments: albumId);

  /// Opens the artist page matching a display label such as
  /// "Da LAB ft. Miu Lê". Returns false when no catalog artist matches.
  static bool openArtistByLabel(BuildContext context, String label) {
    final artist = MusicCatalog.artistByLabel(label);
    if (artist == null) return false;
    openArtist(context, artist.id);
    return true;
  }

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
