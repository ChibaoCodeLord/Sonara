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
    {'key': 'all', 'label': 'Tất cả'},
    {'key': 'playlist', 'label': 'Playlists'},
    {'key': 'liked', 'label': 'Bài hát đã thích (328)'},
    {'key': 'ai-hum', 'label': 'Lịch sử AI Hum (14)'},
    {'key': 'artists', 'label': 'Nghệ sĩ & Album'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = selectedFilter == filter['key'];

          return GestureDetector(
            onTap: () => onFilterSelected(filter['key']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.textCharcoal
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  filter['label']!,
                  style: AppTextStyles.labelMd.copyWith(
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
