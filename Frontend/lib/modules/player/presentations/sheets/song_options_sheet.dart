import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_bottom_sheet.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../../../core/catalog/music_catalog.dart';
import '../../../../core/routes/app_navigator.dart';
import '../../../../core/routes/app_router.dart';
import '../../../playlist/presentations/sheets/add_to_playlist_sheet.dart';
import '../../bloc/player_cubit.dart';
import '../../models/playing_song_model.dart';
import 'queue_sheet.dart';
import 'share_song_sheet.dart';
import 'sleep_timer_sheet.dart';

/// Context menu ("…") for any song across the app.
class SongOptionsSheet extends StatelessWidget {
  final PlayingSongModel song;
  final bool isNowPlaying;

  const SongOptionsSheet({
    super.key,
    required this.song,
    this.isNowPlaying = false,
  });

  static Future<void> show(
    BuildContext context,
    PlayingSongModel song, {
    bool isNowPlaying = false,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      builder: (_) => SongOptionsSheet(song: song, isNowPlaying: isNowPlaying),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artist = MusicCatalog.artistByLabel(song.artist);
    final album = MusicCatalog.albumByTitle(song.album);
    final rootContext = Navigator.of(context).context;
    final player = context.read<PlayerCubit>();

    void closeThen(void Function() action) {
      Navigator.of(context).pop();
      action();
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              AppNetworkImage(
                imageUrl: song.coverUrl,
                width: 56,
                height: 56,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSm.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      song.artist,
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
        const Divider(height: 1, color: AppColors.borderSubtle),
        if (!isNowPlaying) ...[
          SheetActionTile(
            icon: Icons.playlist_play_rounded,
            label: 'Phát tiếp theo',
            onTap: () => closeThen(() {
              player.playAfterCurrent(song);
              AppNavigator.showMessage(rootContext, 'Sẽ phát tiếp theo');
            }),
          ),
          SheetActionTile(
            icon: Icons.queue_music_rounded,
            label: 'Thêm vào hàng đợi',
            onTap: () => closeThen(() {
              player.addToQueue(song);
              AppNavigator.showMessage(rootContext, 'Đã thêm vào hàng đợi');
            }),
          ),
        ],
        SheetActionTile(
          icon: Icons.playlist_add_rounded,
          label: 'Thêm vào danh sách phát',
          onTap: () => closeThen(
            () => AddToPlaylistSheet.show(rootContext, song),
          ),
        ),
        if (artist != null)
          SheetActionTile(
            icon: Icons.person_rounded,
            label: 'Xem nghệ sĩ',
            subtitle: artist.name,
            onTap: () => closeThen(
              () => AppNavigator.openArtist(rootContext, artist.id),
            ),
          ),
        if (album != null)
          SheetActionTile(
            icon: Icons.album_rounded,
            label: 'Xem album',
            subtitle: album.title,
            onTap: () => closeThen(
              () => AppNavigator.openAlbum(rootContext, album.id),
            ),
          ),
        if (isNowPlaying) ...[
          SheetActionTile(
            icon: Icons.queue_music_rounded,
            label: 'Hàng đợi phát nhạc',
            onTap: () => closeThen(() => QueueSheet.show(rootContext)),
          ),
          SheetActionTile(
            icon: Icons.lyrics_rounded,
            label: 'Lời bài hát & Karaoke',
            onTap: () => closeThen(
              () => AppNavigator.push(rootContext, AppRouter.lyrics),
            ),
          ),
          SheetActionTile(
            icon: Icons.bedtime_rounded,
            label: 'Hẹn giờ tắt nhạc',
            onTap: () => closeThen(() => SleepTimerSheet.show(rootContext)),
          ),
          SheetActionTile(
            icon: Icons.equalizer_rounded,
            label: 'Bộ chỉnh âm (Equalizer)',
            onTap: () => closeThen(
              () => AppNavigator.push(rootContext, AppRouter.equalizer),
            ),
          ),
        ],
        SheetActionTile(
          icon: Icons.ios_share_rounded,
          label: 'Chia sẻ',
          subtitle: 'Kèm Sonara Wave Code',
          onTap: () => closeThen(
            () => ShareSongSheet.show(
              rootContext,
              id: song.id,
              title: song.title,
              subtitle: song.artist,
              coverUrl: song.coverUrl,
            ),
          ),
        ),
      ],
    );
  }
}
