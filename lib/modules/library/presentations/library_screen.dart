import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/playing_song_model.dart';
import '../bloc/library_cubit.dart';
import '../bloc/library_state.dart';
import 'widgets/ai_hum_history_card.dart';
import 'widgets/following_artists_row.dart';
import 'widgets/library_filter_chips.dart';
import 'widgets/library_header.dart';
import 'widgets/library_playlist_tile.dart';
import 'widgets/liked_songs_hero_card.dart';
import 'widgets/storage_metric_tile.dart';

class LibraryScreen extends StatelessWidget {
  final VoidCallback onOpenNowPlaying;
  final ValueChanged<String>? onOpenPlaylistDetail;
  final VoidCallback? onProfileTap;

  const LibraryScreen({
    super.key,
    required this.onOpenNowPlaying,
    this.onOpenPlaylistDetail,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) {
          return Column(
            children: [
              // Header
              LibraryHeader(
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
                      // Top Bar Action Row
                      _buildTopBarActions(context),
                      const SizedBox(height: 16),

                      // Filter Chips
                      LibraryFilterChips(
                        selectedFilter: state.selectedFilter,
                        onFilterSelected: (key) {
                          context.read<LibraryCubit>().selectFilter(key);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Hero Highlight 1: Liked Songs Card
                      LikedSongsHeroCard(
                        count: state.likedSongsCount,
                        onPlayTap: () {
                          context.read<PlayerCubit>().playSong(
                                const PlayingSongModel(
                                  id: 'liked_mix',
                                  title: 'Bài Hát Yêu Thích',
                                  artist: 'Offline Lossless 96kHz',
                                  coverUrl:
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDxJ0wA0Fjahrr-T10lBJmzSJyD1-I_F65RxQ5qSW9LuTm9l95D7b9MlDneeNTtMuBQJP7GYI2jS-kgKSebfUQmz12_-fD9LQzOQg_6SVoWsoQcKPP5AkMGfWm3q49lka_CxuFH42rd7wZwCRGmSIMyvCeqe9l_jANsetnGUZiNLOG8zBC0u-KFmrTSRklqw9aAoqRoBVqr5Q2GMnVpIvK3g7uQOgXazrEjzg_g5yA9t6asMuns9yhCXg',
                                  durationSeconds: 240,
                                  currentSeconds: 0,
                                ),
                              );
                          onOpenNowPlaying();
                        },
                        onTap: () {
                          onOpenPlaylistDetail?.call('liked_mix');
                        },
                      ),
                      const SizedBox(height: 16),

                      // Hero Highlight 2: AI Hum Recognition History Card
                      AiHumHistoryCard(
                        recentHum: state.recentHum,
                        totalCount: state.humHistoryCount,
                        onPlayTap: () {
                          context.read<PlayerCubit>().playSong(
                                PlayingSongModel(
                                  id: state.recentHum.id,
                                  title: state.recentHum.title,
                                  artist: state.recentHum.artist,
                                  coverUrl: state.recentHum.coverUrl,
                                  durationSeconds: 210,
                                  currentSeconds: 0,
                                ),
                              );
                          onOpenNowPlaying();
                        },
                        onTap: () {
                          context.read<PlayerCubit>().playSong(
                                PlayingSongModel(
                                  id: state.recentHum.id,
                                  title: state.recentHum.title,
                                  artist: state.recentHum.artist,
                                  coverUrl: state.recentHum.coverUrl,
                                  durationSeconds: 210,
                                  currentSeconds: 0,
                                ),
                              );
                          onOpenNowPlaying();
                        },
                      ),
                      const SizedBox(height: 24),

                      // Following Artists Section
                      FollowingArtistsRow(
                        artists: state.artists,
                        onSeeAllTap: () {},
                        onAddArtistTap: () {},
                      ),
                      const SizedBox(height: 24),

                      // Playlists Section
                      _buildPlaylistsSection(context, state),
                      const SizedBox(height: 20),

                      // Storage Metric Tile
                      StorageMetricTile(
                        metricText: state.storageUsedText,
                        onManageTap: () {},
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

  Widget _buildTopBarActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Thư viện của tôi',
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainer,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.textCharcoal,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x338B001E),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tạo mới',
                    style: AppTextStyles.labelMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaylistsSection(BuildContext context, LibraryState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Danh sách phát',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(8 playlists)',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.swap_vert_rounded,
                  color: AppColors.textCharcoal,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'Gần đây',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.textCharcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.playlists.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final playlist = state.playlists[index];
            return LibraryPlaylistTile(
              playlist: playlist,
              onTap: () {
                onOpenPlaylistDetail?.call(playlist.id);
              },
              onPlayTap: () {
                context.read<PlayerCubit>().playSong(
                      PlayingSongModel(
                        id: playlist.id,
                        title: playlist.title,
                        artist: playlist.creator,
                        coverUrl: playlist.coverUrl,
                        durationSeconds: 225,
                        currentSeconds: 0,
                      ),
                    );
                onOpenNowPlaying();
              },
            );
          },
        ),
      ],
    );
  }
}
