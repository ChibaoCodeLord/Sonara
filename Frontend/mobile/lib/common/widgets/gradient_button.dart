import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Full-width crimson CTA. Set [outlined] for the secondary variant.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final bool isLoading;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.isLoading = false,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final foreground = outlined ? AppColors.primary : Colors.white;

    return Opacity(
      opacity: enabled || isLoading ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              gradient: outlined ? null : AppColors.aiGradient,
              color: outlined ? AppColors.surfaceCrisp : null,
              borderRadius: BorderRadius.circular(999),
              border: outlined
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
                  : null,
              boxShadow: outlined
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x33B3122E),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(foreground),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: foreground, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLg.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
