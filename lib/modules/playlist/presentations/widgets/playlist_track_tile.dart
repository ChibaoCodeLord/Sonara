import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../models/playlist_detail_model.dart';

class PlaylistTrackTile extends StatelessWidget {
  final PlaylistTrackItemModel track;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const PlaylistTrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceCrisp,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x081A1A1A),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Track index number
            SizedBox(
              width: 20,
              child: Text(
                '${track.index}',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),

            // Artwork
            Stack(
              alignment: Alignment.center,
              children: [
                AppNetworkImage(
                  imageUrl: track.coverUrl,
                  width: 48,
                  height: 48,
                  borderRadius: 10,
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Track details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          track.title,
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          track.qualityBadge,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          track.artist,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          '•',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        track.durationText,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Match percentage pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                track.matchPercentage,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),

            // More button
            IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: onMoreTap ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}
