import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

/// Category filter for the chart list.
class ChartCategoryPills extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const ChartCategoryPills({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const _categories = [
    ('all', 'Tổng hợp'),
    ('hum', 'AI Hum'),
    ('lossless', 'Lossless'),
    ('podcast', 'Podcast'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (key, label) = _categories[index];
          final isSelected = selectedCategory == key;
          return GestureDetector(
            onTap: () => onCategorySelected(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceCrisp,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderMuted,
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.labelMd.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
