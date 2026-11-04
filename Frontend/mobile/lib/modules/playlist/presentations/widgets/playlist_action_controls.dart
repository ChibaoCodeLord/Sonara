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
      children: [
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
                  color: Color(0x44B3122E),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onShuffleToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isSmartShuffle
                    ? AppColors.textCharcoal
                    : AppColors.surfaceCrisp,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: isSmartShuffle ? Colors.white : AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Trộn thông minh',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMd.copyWith(
                        color: isSmartShuffle
                            ? Colors.white
                            : AppColors.textCharcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _utilityButton(
          onTap: onDownloadToggle,
          icon: isDownloaded
              ? Icons.check_circle_rounded
              : Icons.download_for_offline_rounded,
          isActive: isDownloaded,
        ),
        const SizedBox(width: 4),
        _utilityButton(
          onTap: onFavoriteToggle,
          icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          isActive: isFavorite,
        ),
      ],
    );
  }

  Widget _utilityButton({
    required VoidCallback onTap,
    required IconData icon,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceCrisp,
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.textCharcoal,
          size: 22,
        ),
      ),
    );
  }
}
