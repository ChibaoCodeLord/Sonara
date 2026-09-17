import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../models/track_model.dart';

class RecommendedTrackItem extends StatelessWidget {
  final TrackModel track;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onFavoriteTap;

  const RecommendedTrackItem({
    super.key,
    required this.track,
    this.onTap,
    this.onPlayTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceCrisp,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 48,
              height: 48,
              child: AppNetworkImage(
                imageUrl: track.imageUrl,
                borderRadius: 12,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Container(
                        width: 3,
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.borderMuted,
                        ),
                      ),
                      Text(
                        '${track.matchPercentage} Khớp gu',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Like Heart Button
            IconButton(
              icon: Icon(
                track.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: track.isFavorite ? AppColors.primary : AppColors.textMuted,
                size: 22,
              ),
              onPressed: onFavoriteTap,
              splashRadius: 20,
            ),
            // Play Button
            GestureDetector(
              onTap: onPlayTap ?? onTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainer,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.textCharcoal,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
