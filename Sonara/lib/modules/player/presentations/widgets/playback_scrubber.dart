import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

class PlaybackScrubber extends StatelessWidget {
  final int currentSeconds;
  final int totalSeconds;
  final ValueChanged<int> onSeek;

  const PlaybackScrubber({
    super.key,
    required this.currentSeconds,
    required this.totalSeconds,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0
        ? (currentSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;
    final remainingSeconds = (totalSeconds - currentSeconds).clamp(0, totalSeconds);

    return Column(
      children: [
        // Slider track
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            final knobX = (trackWidth * progress).clamp(0.0, trackWidth);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                final localX = details.localPosition.dx.clamp(0.0, trackWidth);
                final newRatio = localX / trackWidth;
                final newSecs = (newRatio * totalSeconds).round();
                onSeek(newSecs);
              },
              onTapDown: (details) {
                final localX = details.localPosition.dx.clamp(0.0, trackWidth);
                final newRatio = localX / trackWidth;
                final newSecs = (newRatio * totalSeconds).round();
                onSeek(newSecs);
              },
              child: SizedBox(
                height: 28,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background track
                    Container(
                      height: 5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    // Filled progress track
                    Container(
                      height: 5,
                      width: knobX,
                      decoration: BoxDecoration(
                        gradient: AppColors.miniPlayerProgressGradient,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    // Tactile Knob
                    Positioned(
                      left: (knobX - 8).clamp(0.0, trackWidth - 16),
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceCrisp,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x28000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 2),
        // Timestamps
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Formatters.formatSeconds(currentSeconds),
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              Formatters.formatSeconds(remainingSeconds, negative: true),
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
