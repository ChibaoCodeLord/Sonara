import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_bottom_sheet.dart';
import '../../../core/routes/app_navigator.dart';
import '../../library/bloc/library_cubit.dart';
import '../../hum_to_search/bloc/hum_search_cubit.dart';
import '../../hum_to_search/presentations/hum_to_search_screen.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/playing_song_model.dart';
import '../../player/presentations/now_playing_screen.dart';
import '../../player/presentations/sheets/share_song_sheet.dart';
import '../../player/presentations/sheets/song_options_sheet.dart';
import '../bloc/playlist_cubit.dart';
import '../bloc/playlist_state.dart';
import '../models/playlist_detail_model.dart';
import 'widgets/playlist_action_controls.dart';
import 'widgets/playlist_ai_mood_card.dart';
import 'widgets/playlist_detail_header.dart';
import 'widgets/playlist_floating_hum_capsule.dart';
import 'widgets/playlist_hero_artwork.dart';
import 'widgets/playlist_meta_info.dart';
import 'widgets/playlist_track_tile.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistDetailScreen({
    super.key,
    this.playlistId = 'ai_curated_01',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlaylistCubit(playlistId: playlistId),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: BlocBuilder<PlaylistCubit, PlaylistState>(
          builder: (context, state) {
            final cubit = context.read<PlaylistCubit>();

            return Stack(
              children: [
                Column(
                  children: [
                    // Top App Bar
                    PlaylistDetailHeader(
                      onBackTap: () => Navigator.of(context).pop(),
                      onShareTap: () => ShareSongSheet.show(
                        context,
                        id: state.playlist.id,
                        title: state.playlist.title,
                        subtitle: state.playlist.engineTag,
                        coverUrl: state.playlist.coverUrl,
                      ),
                      onMoreTap: () => _showMoreSheet(context, state.playlist),
                    ),

                    // Scrollable playlist details & tracklist
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hero artwork
                            PlaylistHeroArtwork(
                              coverUrl: state.playlist.coverUrl,
                            ),
                            const SizedBox(height: 20),

                            // Playlist Metadata
                            PlaylistMetaInfo(
                              title: state.playlist.title,
                              engineTag: state.playlist.engineTag,
                              description: state.playlist.description,
                            ),
                            const SizedBox(height: 20),

                            // Action Buttons Cluster
                            PlaylistActionControls(
                              isPlaying: state.isPlaying,
                              isSmartShuffle: state.isSmartShuffle,
                              isDownloaded: state.isDownloaded,
                              isFavorite: state.isFavorite,
                              onPlayToggle: () {
                                cubit.togglePlay();
                                if (!state.isPlaying &&
                                    state.playlist.tracks.isNotEmpty) {
                                  final first = state.playlist.tracks.first;
                                  context.read<PlayerCubit>().playSong(
                                        PlayingSongModel(
                                          id: first.id,
                                          title: first.title,
                                          artist: first.artist,
                                          coverUrl: first.coverUrl,
                                          durationSeconds: 225,
                                          currentSeconds: 0,
                                        ),
                                      );
                                }
                              },
                              onShuffleToggle: () => cubit.toggleSmartShuffle(),
                              onDownloadToggle: () => cubit.toggleDownload(),
                              onFavoriteToggle: () => cubit.toggleFavorite(),
                            ),
                            const SizedBox(height: 20),

                            // AI Acoustic Analysis & Mood Card
                            PlaylistAiMoodCard(
                              emotionAnalysis: state.playlist.emotionAnalysis,
                              selectedMood: state.selectedMood,
                              onMoodSelected: (mood) => cubit.selectMood(mood),
                            ),
                            const SizedBox(height: 24),

                            // Tracklist Section Header
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  'Danh sách bài hát',
                                  style: AppTextStyles.headlineSm.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${state.playlist.tracks.length} bài hát gợi ý',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Track List
                            ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.playlist.tracks.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final track = state.playlist.tracks[index];
                                return PlaylistTrackTile(
                                  track: track,
                                  onMoreTap: () => SongOptionsSheet.show(
                                    context,
                                    _toSong(track),
                                  ),
                                  onTap: () {
                                    context.read<PlayerCubit>().playSong(
                                          PlayingSongModel(
                                            id: track.id,
                                            title: track.title,
                                            artist: track.artist,
                                            coverUrl: track.coverUrl,
                                            durationSeconds: 230,
                                            currentSeconds: 0,
                                          ),
                                        );
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const NowPlayingScreen(),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Floating AI Hum action capsule
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12,
                  child: SafeArea(
                    top: false,
                    child: PlaylistFloatingHumCapsule(
                      onHumTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => HumSearchCubit(),
                              child: const HumToSearchScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static PlayingSongModel _toSong(PlaylistTrackItemModel track) {
    return PlayingSongModel(
      id: track.id,
      title: track.title,
      artist: track.artist,
      coverUrl: track.coverUrl,
      durationSeconds: 230,
      currentSeconds: 0,
    );
  }

  void _showMoreSheet(BuildContext context, PlaylistDetailModel playlist) {
    final player = context.read<PlayerCubit>();
    final library = context.read<LibraryCubit>();
    showAppBottomSheet<void>(
      context: context,
      title: playlist.title,
      subtitle: '${playlist.tracks.length} bài hát',
      builder: (sheetContext) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SheetActionTile(
            icon: Icons.queue_music_rounded,
            label: 'Thêm tất cả vào hàng đợi',
            onTap: () {
              for (final track in playlist.tracks) {
                player.addToQueue(_toSong(track));
              }
              AppNavigator.showMessage(
                context,
                'Đã thêm ${playlist.tracks.length} bài vào hàng đợi',
              );
              Navigator.of(sheetContext).pop();
            },
          ),
          SheetActionTile(
            icon: Icons.library_add_rounded,
            label: 'Lưu bản sao vào Thư viện',
            subtitle: 'Tạo playlist cá nhân từ danh sách này',
            onTap: () {
              library.createPlaylist(
                title: '${playlist.title} (bản sao)',
                description: playlist.description,
                coverUrl: playlist.coverUrl,
                trackCount: playlist.tracks.length,
              );
              AppNavigator.showMessage(context, 'Đã lưu vào Thư viện');
              Navigator.of(sheetContext).pop();
            },
          ),
          SheetActionTile(
            icon: Icons.ios_share_rounded,
            label: 'Chia sẻ',
            onTap: () {
              Navigator.of(sheetContext).pop();
              ShareSongSheet.show(
                context,
                id: playlist.id,
                title: playlist.title,
                subtitle: playlist.engineTag,
                coverUrl: playlist.coverUrl,
              );
            },
          ),
        ],
      ),
    );
  }
}
