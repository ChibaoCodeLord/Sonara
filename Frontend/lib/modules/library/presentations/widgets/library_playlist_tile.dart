import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../models/library_playlist_model.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCrisp,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cover with small indicator icon
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppNetworkImage(
                  imageUrl: playlist.coverUrl,
                  width: 56,
                  height: 56,
                  borderRadius: 12,
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: _buildCornerBadge(),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    style: AppTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          playlist.creator,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm.copyWith(
                            color: playlist.badgeType == 'ai_mood'
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontWeight: playlist.badgeType == 'ai_mood'
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          '•',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '${playlist.trackCount} bài hát',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            IconButton(
              icon: const Icon(
                Icons.play_circle_outline_rounded,
                color: AppColors.textMuted,
                size: 26,
              ),
              onPressed: onPlayTap,
            ),
            if (onMoreTap != null)
              IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: onMoreTap,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerBadge() {
    IconData icon;
    Color bgColor;
    Color iconColor;

    switch (playlist.badgeType) {
      case 'ai_mood':
        icon = Icons.auto_awesome_rounded;
        bgColor = AppColors.aiGradientStart;
        iconColor = Colors.white;
        break;
      case 'auto_mix':
        icon = Icons.bolt_rounded;
        bgColor = AppColors.textCharcoal;
        iconColor = Colors.white;
        break;
      case 'user_created':
      default:
        icon = Icons.person_rounded;
        bgColor = AppColors.surfaceContainerHighest;
        iconColor = AppColors.textCharcoal;
        break;
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Icon(icon, color: iconColor, size: 12),
      ),
    );
  }
}
