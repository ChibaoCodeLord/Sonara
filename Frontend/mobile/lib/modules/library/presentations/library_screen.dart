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
import 'widgets/following_artists_row.dart';
import 'widgets/library_filter_chips.dart';
import 'widgets/library_header.dart';
import 'widgets/library_playlist_tile.dart';
import 'widgets/library_shortcut_grid.dart';

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
          final shortcuts = _buildShortcuts(context, state, filter);
          final showArtists = filter == 'all' || filter == 'artists';
          final showPlaylists = filter == 'all' || filter == 'playlist';

          return Column(
            children: [
              LibraryHeader(
                onProfileTap: onProfileTap,
                onSearchTap: () => AppNavigator.openSearch(context),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 200),
                  children: [
                    LibraryFilterChips(
                      selectedFilter: filter,
                      onFilterSelected: context.read<LibraryCubit>().selectFilter,
                    ),
                    const SizedBox(height: 16),
                    if (shortcuts.isNotEmpty) ...[
                      LibraryShortcutGrid(shortcuts: shortcuts),
                      const SizedBox(height: 28),
                    ],
                    if (showArtists) ...[
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
                    if (showPlaylists) _buildPlaylistsSection(context, state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Quick-access tiles; filters narrow the grid to the matching tile.
  List<LibraryShortcut> _buildShortcuts(
    BuildContext context,
    LibraryState state,
    String filter,
  ) {
    final liked = LibraryShortcut(
      icon: Icons.favorite_rounded,
      title: 'Bài hát yêu thích',
      subtitle: '${state.likedSongsCount} bài',
      highlighted: true,
      onTap: () => onOpenPlaylistDetail?.call('liked_mix'),
    );
    final hum = LibraryShortcut(
      icon: Icons.graphic_eq_rounded,
      title: 'Lịch sử AI Hum',
      subtitle: '${state.humHistoryCount} giai điệu',
      onTap: () => AppNavigator.push(context, AppRouter.humHistory),
    );
    switch (filter) {
      case 'all':
        return [
          liked,
          hum,
          LibraryShortcut(
            icon: Icons.history_rounded,
            title: 'Nghe gần đây',
            subtitle: 'Lịch sử nghe',
            onTap: () => AppNavigator.push(context, AppRouter.listeningHistory),
          ),
          LibraryShortcut(
            icon: Icons.download_for_offline_outlined,
            title: 'Đã tải',
            subtitle: state.storageUsedText.split(' • ').first,
            onTap: () => AppNavigator.push(context, AppRouter.offlineMusic),
          ),
        ];
      case 'liked':
        return [liked];
      case 'ai-hum':
        return [hum];
      default:
        return const [];
    }
  }

  Widget _buildPlaylistsSection(BuildContext context, LibraryState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danh sách phát',
                    style: AppTextStyles.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${state.playlists.length} danh sách',
                    style: AppTextStyles.labelSm,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Tạo playlist',
              onPressed: () => PlaylistEditorSheet.show(context),
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceCrisp,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                for (var i = 0; i < state.playlists.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 76,
                      color: AppColors.borderSubtle,
                    ),
                  _buildPlaylistTile(context, state, i),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistTile(BuildContext context, LibraryState state, int i) {
    final playlist = state.playlists[i];
    return LibraryPlaylistTile(
      playlist: playlist,
      onTap: () => onOpenPlaylistDetail?.call(playlist.id),
      onPlayTap: () => context.read<PlayerCubit>().playSong(
            PlayingSongModel(
              id: playlist.id,
              title: playlist.title,
              artist: playlist.creator,
              coverUrl: playlist.coverUrl,
              durationSeconds: 225,
              currentSeconds: 0,
            ),
          ),
      onMoreTap: playlist.badgeType == 'user_created'
          ? () => PlaylistEditorSheet.show(context, existing: playlist)
          : null,
    );
  }
}
