import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Back-button header shared by every pushed (non-tab) page.
class SubPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackTap;
  final List<Widget> actions;
  final bool showLogo;

  const SubPageHeader({
    super.key,
    required this.title,
    this.onBackTap,
    this.actions = const [],
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              IconButton(
                tooltip: 'Quay lại',
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textCharcoal,
                  size: 24,
                ),
                onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
              ),
              if (showLogo) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppColors.aiGradient,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}
