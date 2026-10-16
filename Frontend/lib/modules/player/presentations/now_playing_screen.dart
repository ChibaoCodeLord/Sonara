import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';
import 'widgets/acoustic_route_chips.dart';
import 'widgets/album_artwork_hero.dart';
import 'widgets/playback_controls_row.dart';
import 'widgets/playback_scrubber.dart';
import 'widgets/synced_lyrics_card.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            final song = state.song;
            final playerCubit = context.read<PlayerCubit>();

            return Column(
              children: [
                // Top Context Bar
                _buildTopBar(context, song.contextHint),

                // Main Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Center Album Artwork Hero
                        AlbumArtworkHero(
                          imageUrl: song.coverUrl,
                          isLossless: song.isLossless,
                        ),
                        const SizedBox(height: 24),

                        // Track Title, Artist, & Actions (Heart, Playlist)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          song.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.headlineMd.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      if (song.isExplicit) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'E',
                                            style: AppTextStyles.labelSm.copyWith(
                                              color: AppColors.textMuted,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    song.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.playlist_add_rounded,
                                    color: AppColors.textCharcoal,
                                    size: 26,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã thêm vào danh sách phát'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    song.isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: song.isFavorite
                                        ? AppColors.secondary
                                        : AppColors.textMuted,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    playerCubit.toggleFavorite();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Playback Scrubber (Timeline)
                        PlaybackScrubber(
                          currentSeconds: song.currentSeconds,
                          totalSeconds: song.durationSeconds,
                          onSeek: (seconds) {
                            playerCubit.seek(seconds);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Playback Controls (Shuffle, Prev, Big Play, Next, Repeat)
                        PlaybackControlsRow(
                          isPlaying: state.isPlaying,
                          isShuffle: state.isShuffle,
                          isRepeat: state.isRepeat,
                          onPlayPause: () => playerCubit.togglePlayPause(),
                          onPrevious: () => playerCubit.playPrevious(),
                          onNext: () => playerCubit.playNext(),
                          onShuffleToggle: () => playerCubit.toggleShuffle(),
                          onRepeatToggle: () => playerCubit.toggleRepeat(),
                        ),
                        const SizedBox(height: 20),

                        // Secondary Acoustic Deck (Spatial 3D & AirPlay)
                        AcousticRouteChips(
                          isSpatialActive: state.isSpatialActive,
                          routeDevice: state.audioRouteDevice,
                          onSpatialToggle: () => playerCubit.toggleSpatialAudio(),
                          onRouteTap: () {},
                        ),
                        const SizedBox(height: 24),

                        // Synced Lyrics Preview Card
                        SyncedLyricsCard(
                          lyrics: state.lyrics,
                          onFullScreenTap: () {},
                        ),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildTopBar(BuildContext context, String contextHint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.expand_more_rounded,
              color: AppColors.textCharcoal,
              size: 32,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PHÁT TỪ GỢI Ý',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.primary,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        contextHint,
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textCharcoal,
              size: 26,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
