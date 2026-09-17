import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../charts/presentations/charts_screen.dart';
import '../../home/presentations/home_screen.dart';
import '../../hum_to_search/bloc/hum_search_cubit.dart';
import '../../hum_to_search/presentations/hum_to_search_screen.dart';
import '../../library/presentations/library_screen.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/bloc/player_state.dart';
import '../../player/presentations/now_playing_screen.dart';
import '../../player/presentations/widgets/mini_player_bar.dart';
import '../../playlist/presentations/playlist_detail_screen.dart';
import '../../profile/presentations/profile_screen.dart';
import '../bloc/app_cubit.dart';
import '../bloc/app_state.dart';
import 'widgets/main_bottom_nav_bar.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: Stack(
            children: [
              // Screen content by tab index
              IndexedStack(
                index: appState.currentTabIndex,
                children: [
                  HomeScreen(
                    onOpenHumSearch: () => _openHumToSearch(context),
                    onOpenNowPlaying: () => _openNowPlaying(context),
                    onOpenPlaylistDetail: (id) =>
                        _openPlaylistDetail(context, id),
                    onProfileTap: () => context.read<AppCubit>().setTab(3),
                  ),
                  LibraryScreen(
                    onOpenNowPlaying: () => _openNowPlaying(context),
                    onOpenPlaylistDetail: (id) =>
                        _openPlaylistDetail(context, id),
                    onProfileTap: () => context.read<AppCubit>().setTab(3),
                  ),
                  ChartsScreen(
                    onOpenNowPlaying: () => _openNowPlaying(context),
                    onOpenHumSearch: () => _openHumToSearch(context),
                    onProfileTap: () => context.read<AppCubit>().setTab(3),
                  ),
                  const ProfileScreen(),
                ],
              ),

              // Floating Sticky Mini Player Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 80,
                child: BlocBuilder<PlayerCubit, PlayerState>(
                  builder: (context, playerState) {
                    final cubit = context.read<PlayerCubit>();
                    return MiniPlayerBar(
                      song: playerState.song,
                      isPlaying: playerState.isPlaying,
                      onTap: () => _openNowPlaying(context),
                      onPlayPauseTap: () => cubit.togglePlayPause(),
                      onNextTap: () => cubit.playNext(),
                    );
                  },
                ),
              ),

              // Bottom Navigation Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MainBottomNavBar(
                  currentIndex: appState.currentTabIndex,
                  onTabSelected: (index) {
                    context.read<AppCubit>().setTab(index);
                  },
                  onHumTap: () => _openHumToSearch(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openHumToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => HumSearchCubit(),
          child: const HumToSearchScreen(),
        ),
      ),
    );
  }

  void _openNowPlaying(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NowPlayingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _openPlaylistDetail(BuildContext context, String playlistId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaylistDetailScreen(playlistId: playlistId),
      ),
    );
  }
}
