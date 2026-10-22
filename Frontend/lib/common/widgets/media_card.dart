import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'app_network_image.dart';

/// Vertical cover card for horizontal carousels (albums, artists, mixes).
class MediaCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isCircle;
  final double size;

  const MediaCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isCircle = false,
    this.size = 136,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment:
              isCircle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            AppNetworkImage(
              imageUrl: imageUrl,
              width: size,
              height: size,
              borderRadius: isCircle ? 999 : 16,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isCircle ? TextAlign.center : TextAlign.start,
              style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isCircle ? TextAlign.center : TextAlign.start,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
