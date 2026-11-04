import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

class LibraryFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const LibraryFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  static const _filters = [
    ('all', 'Tất cả'),
    ('playlist', 'Playlist'),
    ('liked', 'Đã thích'),
    ('ai-hum', 'AI Hum'),
    ('artists', 'Nghệ sĩ'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (key, label) = _filters[index];
          final isSelected = selectedFilter == key;

          return GestureDetector(
            onTap: () => onFilterSelected(key),
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
