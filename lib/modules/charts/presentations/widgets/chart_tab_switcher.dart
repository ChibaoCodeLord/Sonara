import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/pulsing_dot.dart';

class ChartTabSwitcher extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;
  final String lastUpdatedText;

  const ChartTabSwitcher({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    required this.lastUpdatedText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Subheader timestamp & sonic indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const PulsingDot(
                  color: AppColors.primary,
                  size: 7,
                ),
                const SizedBox(width: 8),
                Text(
                  lastUpdatedText.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.equalizer_rounded,
                  color: AppColors.textMuted,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'AI Sonic Realtime',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Tab selector switch
        Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  title: 'Việt Nam Hot 50',
                  icon: Icons.star_rounded,
                  isActive: activeTab == 'vn',
                  onTap: () => onTabChanged('vn'),
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  title: 'Quốc Tế Viral',
                  icon: Icons.public_rounded,
                  isActive: activeTab == 'global',
                  onTap: () => onTabChanged('global'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isActive
            ? const [
                BoxShadow(
                  color: Color(0x338B001E),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppColors.textMuted,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles.labelMd.copyWith(
                color: isActive ? Colors.white : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
