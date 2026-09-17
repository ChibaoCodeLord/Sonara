import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../home/presentations/home_screen.dart';
import '../../hum_to_search/bloc/hum_search_cubit.dart';
import '../../hum_to_search/presentations/hum_to_search_screen.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/bloc/player_state.dart';
import '../../player/presentations/now_playing_screen.dart';
import '../../player/presentations/widgets/mini_player_bar.dart';
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
                  ),
                  _buildPlaceholderScreen('Thư viện', Icons.library_music_rounded),
                  _buildPlaceholderScreen('Bảng xếp hạng', Icons.trending_up_rounded),
                  _buildPlaceholderScreen('Hồ sơ cá nhân', Icons.person_rounded),
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

  Widget _buildPlaceholderScreen(String title, IconData icon) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainer,
                ),
                child: Icon(icon, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTextStyles.headlineMd.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tính năng đang được Resonance AI phát triển',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
