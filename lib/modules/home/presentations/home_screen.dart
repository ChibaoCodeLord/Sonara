import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/pulsing_dot.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/playing_song_model.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import 'widgets/home_header.dart';
import 'widgets/hum_hero_banner.dart';
import 'widgets/playlist_card.dart';
import 'widgets/recommended_track_item.dart';
import 'widgets/trending_chart_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenHumSearch;
  final VoidCallback onOpenNowPlaying;
  final ValueChanged<String>? onOpenPlaylistDetail;
  final VoidCallback? onProfileTap;

  const HomeScreen({
    super.key,
    required this.onOpenHumSearch,
    required this.onOpenNowPlaying,
    this.onOpenPlaylistDetail,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Column(
            children: [
              HomeHeader(
                onNotificationTap: () {},
                onProfileTap: onProfileTap,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting & AI Status Bar
                      _buildGreetingBar(),
                      const SizedBox(height: 16),

                      // Hum & Whistle Hero Banner
                      HumHeroBanner(
                        onHumSearchTap: onOpenHumSearch,
                      ),
                      const SizedBox(height: 28),

                      // Section 1: AI Recommended Playlists
                      _buildAiMixesSection(context, state),
                      const SizedBox(height: 28),

                      // Section 2: Recommended Tracks Matching Taste
                      _buildRecommendedTracksSection(context, state),
                      const SizedBox(height: 28),

                      // Section 3: Trending Charts
                      TrendingChartCard(
                        charts: state.trendingCharts,
                        isWeekly: state.isWeeklyChart,
                        onTimeframeChanged: (val) {
                          context.read<HomeCubit>().setChartTimeframe(val);
                        },
                        onTrackTap: (chartItem) {
                          context.read<PlayerCubit>().playSong(
                                PlayingSongModel(
                                  id: chartItem.rank,
                                  title: chartItem.title,
                                  artist: chartItem.artist,
                                  coverUrl: chartItem.imageUrl,
                                  durationSeconds: 215,
                                  currentSeconds: 0,
                                ),
                              );
                          onOpenNowPlaying();
                        },
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

  Widget _buildGreetingBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHÀO BUỔI TỐI',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Giai điệu khơi nguồn cảm xúc',
              style: AppTextStyles.headlineSm.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        // AI Active status pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PulsingDot(
                color: AppColors.primary,
                size: 7,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Active',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAiMixesSection(BuildContext context, HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DÀNH RIÊNG CHO BẠN',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Resonance AI Mixes',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    'Xem thêm',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 228,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: state.aiMixes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final playlist = state.aiMixes[index];
              return PlaylistCard(
                playlist: playlist,
                onTap: () {
                  if (onOpenPlaylistDetail != null) {
                    onOpenPlaylistDetail!(playlist.id);
                  } else {
                    context.read<PlayerCubit>().playSong(
                          PlayingSongModel(
                            id: playlist.id,
                            title: playlist.title,
                            artist: 'Resonance AI Curated',
                            coverUrl: playlist.imageUrl,
                            durationSeconds: 220,
                            currentSeconds: 0,
                          ),
                        );
                    onOpenNowPlaying();
                  }
                },
                onPlayTap: () {
                  context.read<PlayerCubit>().playSong(
                        PlayingSongModel(
                          id: playlist.id,
                          title: playlist.title,
                          artist: 'Resonance AI Curated',
                          coverUrl: playlist.imageUrl,
                          durationSeconds: 220,
                          currentSeconds: 0,
                        ),
                      );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedTracksSection(BuildContext context, HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KHÁM PHÁ MỚI',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Gợi ý khớp với gu bạn',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    color: AppColors.textMuted,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tùy chỉnh',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.recommendedTracks.length,
          itemBuilder: (context, index) {
            final track = state.recommendedTracks[index];
            return RecommendedTrackItem(
              track: track,
              onFavoriteTap: () {
                context.read<HomeCubit>().toggleFavorite(track.id);
              },
              onTap: () {
                context.read<PlayerCubit>().playSong(
                      PlayingSongModel(
                        id: track.id,
                        title: track.title,
                        artist: track.artist,
                        coverUrl: track.imageUrl,
                        durationSeconds: 235,
                        currentSeconds: 0,
                      ),
                    );
                onOpenNowPlaying();
              },
              onPlayTap: () {
                context.read<PlayerCubit>().playSong(
                      PlayingSongModel(
                        id: track.id,
                        title: track.title,
                        artist: track.artist,
                        coverUrl: track.imageUrl,
                        durationSeconds: 235,
                        currentSeconds: 0,
                      ),
                    );
              },
            );
          },
        ),
      ],
    );
  }
}
