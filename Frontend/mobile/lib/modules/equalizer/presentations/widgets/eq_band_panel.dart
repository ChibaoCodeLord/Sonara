import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

/// Graphic EQ: vertical band sliders over a smooth response curve.
class EqBandPanel extends StatelessWidget {
  final List<double> gains;
  final List<String> labels;
  final bool enabled;
  final void Function(int index, double gain) onChanged;

  const EqBandPanel({
    super.key,
    required this.gains,
    required this.labels,
    required this.enabled,
    required this.onChanged,
  });

  static const double maxGain = 12;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        height: 260,
        padding: const EdgeInsets.fromLTRB(6, 14, 6, 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceCrisp,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _CurvePainter(gains)),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < gains.length; i++)
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor: AppColors.surfaceContainer,
                                thumbColor: AppColors.primary,
                                overlayColor:
                                    AppColors.primary.withValues(alpha: 0.12),
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7,
                                ),
                              ),
                              child: Slider(
                                value: gains[i].clamp(-maxGain, maxGain),
                                min: -maxGain,
                                max: maxGain,
                                onChanged: enabled
                                    ? (value) => onChanged(i, value)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 0; i < gains.length; i++)
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${gains[i] > 0 ? '+' : ''}${gains[i].toStringAsFixed(0)}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: gains[i] == 0
                                ? AppColors.textMuted
                                : AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          labels[i],
                          style: AppTextStyles.labelSm.copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  final List<double> gains;

  _CurvePainter(this.gains);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.borderSubtle
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      grid,
    );

    if (gains.isEmpty) return;
    final step = size.width / gains.length;
    final points = [
      for (var i = 0; i < gains.length; i++)
        Offset(
          step * i + step / 2,
          size.height / 2 - (gains[i] / EqBandPanel.maxGain) * (size.height / 2 - 12),
        ),
    ];

    final path = Path()..moveTo(0, points.first.dy);
    path.lineTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = (p0.dx + p1.dx) / 2;
      path.cubicTo(mid, p0.dy, mid, p1.dy, p1.dx, p1.dy);
    }
    path.lineTo(size.width, points.last.dy);

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.aiGradientEnd.withValues(alpha: 0.22),
            AppColors.aiGradientEnd.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.aiGradientEnd.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
      oldDelegate.gains != gains;
}
