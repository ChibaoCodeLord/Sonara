import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onHumTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onHumTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCrisp,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F1A1A1A),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tab 0: Khám phá
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Khám phá',
                isSelected: currentIndex == 0,
              ),
              // Tab 1: Thư viện
              _buildNavItem(
                index: 1,
                icon: Icons.library_music_rounded,
                label: 'Thư viện',
                isSelected: currentIndex == 1,
              ),
              // Center AI Hum Button
              _buildCenterHumButton(),
              // Tab 3: Xếp hạng
              _buildNavItem(
                index: 2,
                icon: Icons.trending_up_rounded,
                label: 'Xếp hạng',
                isSelected: currentIndex == 2,
              ),
              // Tab 4: Hồ sơ
              _buildNavItem(
                index: 3,
                icon: Icons.person_rounded,
                label: 'Hồ sơ',
                isSelected: currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final color = isSelected ? AppColors.primary : AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterHumButton() {
    return SizedBox(
      width: 64,
      child: OverflowBox(
        maxHeight: 90,
        alignment: Alignment.center,
        child: Transform.translate(
          offset: const Offset(0, -6),
          child: GestureDetector(
            onTap: onHumTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
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
                  child: const Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'AI HUM',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
