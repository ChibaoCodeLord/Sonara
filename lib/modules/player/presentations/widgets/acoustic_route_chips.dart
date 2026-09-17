import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/pulsing_dot.dart';

class AcousticRouteChips extends StatelessWidget {
  final bool isSpatialActive;
  final String routeDevice;
  final VoidCallback onSpatialToggle;
  final VoidCallback? onRouteTap;

  const AcousticRouteChips({
    super.key,
    required this.isSpatialActive,
    required this.routeDevice,
    required this.onSpatialToggle,
    this.onRouteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // AI Audio Enhancer / Spatial Audio Pill
        GestureDetector(
          onTap: onSpatialToggle,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.spatial_audio_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resonance Spatial 3D',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isSpatialActive) ...[
                  const SizedBox(width: 6),
                  const PulsingDot(
                    color: AppColors.primary,
                    size: 6,
                  ),
                ],
              ],
            ),
          ),
        ),
        // AirPlay / Audio Route Hub
        GestureDetector(
          onTap: onRouteTap ?? () {},
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.airplay_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  routeDevice,
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
