import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../models/library_playlist_model.dart';

/// Flat playlist row, meant to sit inside a shared card with dividers.
class LibraryPlaylistTile extends StatelessWidget {
  final LibraryPlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;
  final VoidCallback? onMoreTap;

  const LibraryPlaylistTile({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.onPlayTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          children: [
            AppNetworkImage(
              imageUrl: playlist.coverUrl,
              width: 52,
              height: 52,
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
                    '${playlist.badgeLabel} • ${playlist.trackCount} bài hát',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: onMoreTap != null ? 'Chỉnh sửa' : 'Phát',
              onPressed: onMoreTap ?? onPlayTap,
              icon: Icon(
                onMoreTap != null
                    ? Icons.more_vert_rounded
                    : Icons.play_arrow_rounded,
                color: onMoreTap != null
                    ? AppColors.textMuted
                    : AppColors.textCharcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
