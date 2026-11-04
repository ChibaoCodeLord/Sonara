import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_bottom_sheet.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../../../core/routes/app_navigator.dart';
import '../../../library/bloc/library_cubit.dart';
import '../../../library/bloc/library_state.dart';
import '../../../player/models/playing_song_model.dart';
import 'playlist_editor_sheet.dart';

/// Lets the user drop a song into one of their playlists or a new one.
class AddToPlaylistSheet extends StatelessWidget {
  final PlayingSongModel song;

  const AddToPlaylistSheet({super.key, required this.song});

  static Future<void> show(BuildContext context, PlayingSongModel song) {
    return showAppBottomSheet<void>(
      context: context,
      title: 'Thêm vào danh sách phát',
      subtitle: '${song.title} • ${song.artist}',
      builder: (_) => AddToPlaylistSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            SheetActionTile(
              icon: Icons.add_rounded,
              color: AppColors.primary,
              label: 'Tạo playlist mới',
              subtitle: 'Bài hát sẽ được thêm ngay sau khi tạo',
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final libraryCubit = context.read<LibraryCubit>();
                final created = await PlaylistEditorSheet.show(context);
                if (created == null) return;
                libraryCubit.addSongToPlaylist(created.id);
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Đã thêm vào "${created.title}"')),
                );
              },
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            for (final playlist in state.playlists)
              InkWell(
                onTap: () {
                  AppNavigator.showMessage(
                    context,
                    'Đã thêm vào "${playlist.title}"',
                  );
                  context.read<LibraryCubit>().addSongToPlaylist(playlist.id);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      AppNetworkImage(
                        imageUrl: playlist.coverUrl,
                        width: 48,
                        height: 48,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playlist.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelLg.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${playlist.trackCount} bài hát • ${playlist.badgeLabel}',
                              style: AppTextStyles.bodySm,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
