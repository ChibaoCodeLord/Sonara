import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

class ChartCategoryPills extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const ChartCategoryPills({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Tổng hợp
          _buildPill(
            keyId: 'all',
            label: 'Tổng hợp',
            isSelected: selectedCategory == 'all',
          ),
          const SizedBox(width: 8),

          // 2. AI Hum Trending
          _buildPill(
            keyId: 'hum',
            label: 'AI Hum Trending',
            icon: Icons.graphic_eq_rounded,
            iconColor: AppColors.primary,
            badge: 'Hot',
            isSelected: selectedCategory == 'hum',
          ),
          const SizedBox(width: 8),

          // 3. Lossless Master
          _buildPill(
            keyId: 'lossless',
            label: 'Lossless Master',
            icon: Icons.audio_file_rounded,
            iconColor: AppColors.textMuted,
            isSelected: selectedCategory == 'lossless',
          ),
          const SizedBox(width: 8),

          // 4. Podcast AI
          _buildPill(
            keyId: 'podcast',
            label: 'Podcast AI',
            icon: Icons.podcasts_rounded,
            iconColor: AppColors.textMuted,
            isSelected: selectedCategory == 'podcast',
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String keyId,
    required String label,
    IconData? icon,
    Color? iconColor,
    String? badge,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onCategorySelected(keyId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.textCharcoal
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : (iconColor ?? AppColors.textMuted),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.tertiary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
