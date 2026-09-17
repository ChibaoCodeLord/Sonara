import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

class PlaylistAiMoodCard extends StatelessWidget {
  final String emotionAnalysis;
  final String selectedMood;
  final ValueChanged<String> onMoodSelected;

  const PlaylistAiMoodCard({
    super.key,
    required this.emotionAnalysis,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const _moods = [
    {'key': 'default', 'label': 'Mặc định AI'},
    {'key': 'peaceful', 'label': 'Bình yên'},
    {'key': 'energetic', 'label': 'Sôi động'},
    {'key': 'focus', 'label': 'Tập trung'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCrisp,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1A1A1A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emotion Analysis Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.psychology_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Phân tích cảm xúc:',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  emotionAnalysis,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mood filter swiper
          Text(
            'Tinh chỉnh tần số AI:',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _moods.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final mood = _moods[index];
                final isSelected = selectedMood == mood['key'];

                return GestureDetector(
                  onTap: () => onMoodSelected(mood['key']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.textCharcoal
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(
                        mood['label']!,
                        style: AppTextStyles.labelMd.copyWith(
                          color: isSelected ? Colors.white : AppColors.textMuted,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
