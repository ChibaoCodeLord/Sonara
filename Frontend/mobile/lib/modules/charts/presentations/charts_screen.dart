import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../core/catalog/catalog_models.dart';
import '../../../core/routes/app_navigator.dart';
import '../../../core/routes/app_router.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/playing_song_model.dart';
import '../bloc/charts_cubit.dart';
import '../bloc/charts_state.dart';
import '../models/chart_item_model.dart';
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
                onProfileTap: onProfileTap,
                onSearchTap: () => AppNavigator.openSearch(context),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Region switcher
                      ChartTabSwitcher(
                        activeTab: state.activeTab,
                        onTabChanged: (tab) => cubit.switchTab(tab),
                      ),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 28),

                      // Top 1-5 Chart Section
                      _buildTopChartSection(context, state),
                      const SizedBox(height: 28),

                      // Mood & Genre Discovery Grid
                      MoodGenreGrid(
                        moods: state.moodGenres,
                        onMoodTap: (mood) => AppNavigator.push(
                          context,
                          AppRouter.categoryDetail,
                          arguments: CatalogCategory(
                            id: mood.id,
                            title: mood.title,
                            subtitle: mood.subtitle,
                            icon: mood.icon,
                            colors: [
                              AppColors.tertiary,
                              mood.dotColor.withValues(alpha: 1),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

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
    final cubit = context.read<ChartsCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top 5 tuần này',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.lastUpdatedText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSm,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => AppNavigator.push(
                context,
                AppRouter.fullChart,
                arguments: state.activeTab,
              ),
              child: Text(
                'Xem tất cả',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Category filter sits right above the list it filters
        ChartCategoryPills(
          selectedCategory: state.selectedCategory,
          onCategorySelected: cubit.selectCategory,
        ),
        const SizedBox(height: 12),

        // Chart rows grouped in one card
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceCrisp,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                for (var i = 0; i < state.chartItems.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 108,
                      color: AppColors.borderSubtle,
                    ),
                  _buildRow(context, state.chartItems[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, ChartItemModel item) {
    final song = PlayingSongModel(
      id: item.rank,
      title: item.title,
      artist: item.artist,
      coverUrl: item.imageUrl,
      durationSeconds: 228,
      currentSeconds: 0,
    );
    return ChartRankTile(
      item: item,
      onPlayTap: () => context.read<PlayerCubit>().playSong(song),
      onTap: () => _playTrack(
        context,
        title: item.title,
        artist: item.artist,
        coverUrl: item.imageUrl,
        id: item.rank,
      ),
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
