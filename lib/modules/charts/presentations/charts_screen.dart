import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/playing_song_model.dart';
import '../bloc/charts_cubit.dart';
import '../bloc/charts_state.dart';
import 'widgets/chart_category_pills.dart';
import 'widgets/chart_rank_tile.dart';
import 'widgets/chart_tab_switcher.dart';
import 'widgets/charts_header.dart';
import 'widgets/hum_quick_invite_card.dart';
import 'widgets/mood_genre_grid.dart';
import 'widgets/spotlight_radar_card.dart';

class ChartsScreen extends StatelessWidget {
  final VoidCallback onOpenNowPlaying;
  final VoidCallback onOpenHumSearch;
  final VoidCallback? onProfileTap;

  const ChartsScreen({
    super.key,
    required this.onOpenNowPlaying,
    required this.onOpenHumSearch,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocBuilder<ChartsCubit, ChartsState>(
        builder: (context, state) {
          final cubit = context.read<ChartsCubit>();

          return Column(
            children: [
              // Header
              ChartsHeader(
                onSearchTap: () {},
                onProfileTap: onProfileTap,
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subheader switcher & realtime status
                      ChartTabSwitcher(
                        activeTab: state.activeTab,
                        onTabChanged: (tab) => cubit.switchTab(tab),
                        lastUpdatedText: state.lastUpdatedText,
                      ),
                      const SizedBox(height: 14),

                      // Category Pills
                      ChartCategoryPills(
                        selectedCategory: state.selectedCategory,
                        onCategorySelected: (cat) => cubit.selectCategory(cat),
                      ),
                      const SizedBox(height: 18),

                      // Spotlight Banner: AI Radar Tuần Này
                      SpotlightRadarCard(
                        spotlight: state.spotlight,
                        onPlayTap: () => _playTrack(
                          context,
                          title: state.spotlight.title,
                          artist: state.spotlight.artist,
                          coverUrl: state.spotlight.coverUrl,
                          id: 'radar_spotlight',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Top 1-5 Chart Section
                      _buildTopChartSection(context, state),
                      const SizedBox(height: 28),

                      // Mood & Genre Discovery Grid
                      MoodGenreGrid(
                        moods: state.moodGenres,
                        onMoodTap: (mood) {},
                      ),
                      const SizedBox(height: 24),

                      // AI Hum Quick Invitation Strip
                      HumQuickInviteCard(
                        onTryNowTap: onOpenHumSearch,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopChartSection(BuildContext context, ChartsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Bảng Xếp Hạng',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'TOP 5',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Xem 50 bài',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List of Chart Items
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.chartItems.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = state.chartItems[index];
            return ChartRankTile(
              item: item,
              onPlayTap: () => _playTrack(
                context,
                title: item.title,
                artist: item.artist,
                coverUrl: item.imageUrl,
                id: item.rank,
              ),
              onTap: () => _playTrack(
                context,
                title: item.title,
                artist: item.artist,
                coverUrl: item.imageUrl,
                id: item.rank,
              ),
            );
          },
        ),
      ],
    );
  }

  void _playTrack(
    BuildContext context, {
    required String id,
    required String title,
    required String artist,
    required String coverUrl,
  }) {
    context.read<PlayerCubit>().playSong(
          PlayingSongModel(
            id: id,
            title: title,
            artist: artist,
            coverUrl: coverUrl,
            durationSeconds: 228,
            currentSeconds: 0,
          ),
        );
    onOpenNowPlaying();
  }
}
