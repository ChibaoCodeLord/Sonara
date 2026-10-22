import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../core/routes/app_navigator.dart';
import '../../../core/routes/app_router.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/playing_song_model.dart';
import '../../playlist/presentations/sheets/playlist_editor_sheet.dart';
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
          final filter = state.selectedFilter;
          bool show(String section) => filter == 'all' || filter == section;

          return Column(
            children: [
              // Header
              LibraryHeader(
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
                      // Filter Chips
                      LibraryFilterChips(
                        selectedFilter: state.selectedFilter,
                        onFilterSelected: (key) {
                          context.read<LibraryCubit>().selectFilter(key);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Hero Highlight 1: Liked Songs Card
                      if (show('liked')) ...[
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
                      ],

                      // Hero Highlight 2: AI Hum Recognition History Card
                      if (show('ai-hum')) ...[
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
                          onTap: () =>
                              AppNavigator.push(context, AppRouter.humHistory),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (filter == 'all') ...[
                        _QuickLinksRow(
                          onHistoryTap: () => AppNavigator.push(
                            context,
                            AppRouter.listeningHistory,
                          ),
                          onOfflineTap: () => AppNavigator.push(
                            context,
                            AppRouter.offlineMusic,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Following Artists Section
                      if (show('artists')) ...[
                        FollowingArtistsRow(
                          artists: state.artists,
                          onArtistTap: (artist) =>
                              AppNavigator.openArtist(context, artist.id),
                          onSeeAllTap: () => AppNavigator.push(
                            context,
                            AppRouter.followingArtists,
                          ),
                          onAddArtistTap: () => AppNavigator.push(
                            context,
                            AppRouter.tastePicker,
                            arguments: false,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Playlists Section
                      if (show('playlist')) ...[
                        _buildPlaylistsSection(context, state),
                        const SizedBox(height: 20),
                      ],

                      // Storage Metric Tile
                      if (filter == 'all')
                        StorageMetricTile(
                          metricText: state.storageUsedText,
                          onManageTap: () => AppNavigator.push(
                            context,
                            AppRouter.offlineMusic,
                          ),
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
              '(${state.playlists.length} danh sách)',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            GestureDetector(
              onTap: () => PlaylistEditorSheet.show(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tạo mới',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
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
              onMoreTap: playlist.badgeType == 'user_created'
                  ? () => PlaylistEditorSheet.show(context, existing: playlist)
                  : null,
            );
          },
        ),
      ],
    );
  }
}

class _QuickLinksRow extends StatelessWidget {
  final VoidCallback onHistoryTap;
  final VoidCallback onOfflineTap;

  const _QuickLinksRow({
    required this.onHistoryTap,
    required this.onOfflineTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget link(IconData icon, String title, String subtitle, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCrisp,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLg.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        link(Icons.history_rounded, 'Nghe gần đây', 'Lịch sử nghe', onHistoryTap),
        const SizedBox(width: 10),
        link(
          Icons.download_for_offline_outlined,
          'Đã tải',
          'Nghe ngoại tuyến',
          onOfflineTap,
        ),
      ],
    );
  }
}
