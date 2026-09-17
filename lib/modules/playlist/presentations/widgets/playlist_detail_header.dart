import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

class PlaylistDetailHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onMoreTap;

  const PlaylistDetailHeader({
    super.key,
    required this.onBackTap,
    this.onShareTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textCharcoal,
                  size: 24,
                ),
                onPressed: onBackTap,
              ),
              const SizedBox(width: 4),
              // Logo icon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppColors.aiGradient,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Center(
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Chi Tiết Playlist',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.share_rounded,
                  color: AppColors.textCharcoal,
                  size: 22,
                ),
                onPressed: onShareTap ?? () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textCharcoal,
                  size: 22,
                ),
                onPressed: onMoreTap ?? () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
