import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

class SocialLoginRow extends StatelessWidget {
  final ValueChanged<String> onProviderTap;
  final bool enabled;

  const SocialLoginRow({
    super.key,
    required this.onProviderTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    const providers = [
      ('Google', Icons.g_mobiledata_rounded),
      ('Apple ID', Icons.apple_rounded),
      ('Facebook', Icons.facebook_rounded),
    ];

    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.borderMuted)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('hoặc tiếp tục với', style: AppTextStyles.bodySm),
            ),
            const Expanded(child: Divider(color: AppColors.borderMuted)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final (name, icon) in providers) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: enabled ? () => onProviderTap(name) : null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surfaceCrisp,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.borderMuted),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Icon(icon, color: AppColors.textCharcoal, size: 26),
                ),
              ),
              if (name != providers.last.$1) const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }
}
