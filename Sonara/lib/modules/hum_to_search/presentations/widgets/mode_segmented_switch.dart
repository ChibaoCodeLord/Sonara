import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../bloc/hum_search_state.dart';

class ModeSegmentedSwitch extends StatelessWidget {
  final HumAcousticMode currentMode;
  final ValueChanged<HumAcousticMode> onModeChanged;

  const ModeSegmentedSwitch({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              title: 'Hát / Hum',
              icon: Icons.record_voice_over_rounded,
              isSelected: currentMode == HumAcousticMode.hum,
              onTap: () => onModeChanged(HumAcousticMode.hum),
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              title: 'Nghe quanh đây',
              icon: Icons.music_note_rounded,
              isSelected: currentMode == HumAcousticMode.ambient,
              onTap: () => onModeChanged(HumAcousticMode.ambient),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceCrisp : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMd.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
