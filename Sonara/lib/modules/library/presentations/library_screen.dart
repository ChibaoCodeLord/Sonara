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
              LibraryHeader(onProfileTap: onProfileTap),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              coverUrl: 'assets/images/sonara_ai_mix.jpg',
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

  Widget _buildPlaylistsSection(BuildContext context, LibraryState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              'Danh sách phát',
              style: AppTextStyles.headlineSm.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '(8 danh sách)',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textMuted,
              ),
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
