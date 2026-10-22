import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../core/routes/app_navigator.dart';
import '../../../../core/routes/app_router.dart';

/// Recap banner plus shortcuts to Premium, history and offline music.
class ProfileQuickLinks extends StatelessWidget {
  const ProfileQuickLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => AppNavigator.push(context, AppRouter.recap),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sonara Recap ${DateTime.now().year}',
                        style: AppTextStyles.headlineSm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Năm âm nhạc của bạn đã sẵn sàng',
                        style: AppTextStyles.bodySm.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 34),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Shortcut(
              icon: Icons.workspace_premium_rounded,
              label: 'Premium',
              onTap: () => AppNavigator.push(context, AppRouter.premium),
            ),
            const SizedBox(width: 10),
            _Shortcut(
              icon: Icons.history_rounded,
              label: 'Nghe gần đây',
              onTap: () =>
                  AppNavigator.push(context, AppRouter.listeningHistory),
            ),
            const SizedBox(width: 10),
            _Shortcut(
              icon: Icons.download_for_offline_outlined,
              label: 'Đã tải',
              onTap: () => AppNavigator.push(context, AppRouter.offlineMusic),
            ),
            const SizedBox(width: 10),
            _Shortcut(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Wave Code',
              onTap: () =>
                  AppNavigator.push(context, AppRouter.waveCodeScanner),
            ),
          ],
        ),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceCrisp,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.textCharcoal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
