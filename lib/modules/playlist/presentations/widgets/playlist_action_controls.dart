import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

class PlaylistActionControls extends StatelessWidget {
  final bool isPlaying;
  final bool isSmartShuffle;
  final bool isDownloaded;
  final bool isFavorite;
  final VoidCallback onPlayToggle;
  final VoidCallback onShuffleToggle;
  final VoidCallback onDownloadToggle;
  final VoidCallback onFavoriteToggle;

  const PlaylistActionControls({
    super.key,
    required this.isPlaying,
    required this.isSmartShuffle,
    required this.isDownloaded,
    required this.isFavorite,
    required this.onPlayToggle,
    required this.onShuffleToggle,
    required this.onDownloadToggle,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Play & Smart Shuffle cluster
        Row(
          children: [
            // Big Gradient Play Button
            GestureDetector(
              onTap: onPlayToggle,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.aiGradient,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66B3122E),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Smart Shuffle AI button
            GestureDetector(
              onTap: onShuffleToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSmartShuffle
                      ? AppColors.textCharcoal
                      : AppColors.surfaceCrisp,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: isSmartShuffle ? Colors.white : AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Smart Shuffle',
                      style: AppTextStyles.labelMd.copyWith(
                        color: isSmartShuffle
                            ? Colors.white
                            : AppColors.textCharcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Secondary Utility Buttons
        Row(
          children: [
            // Download button
            GestureDetector(
              onTap: onDownloadToggle,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceCrisp,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isDownloaded
                        ? Icons.check_circle_rounded
                        : Icons.download_for_offline_rounded,
                    color: isDownloaded
                        ? AppColors.primary
                        : AppColors.textCharcoal,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Favorite button
            GestureDetector(
              onTap: onFavoriteToggle,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceCrisp,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite
                        ? AppColors.primary
                        : AppColors.textCharcoal,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
