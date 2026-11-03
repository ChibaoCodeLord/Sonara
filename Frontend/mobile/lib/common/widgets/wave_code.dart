import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Sonara Wave Code: a scannable soundwave barcode generated from an id.
class WaveCode extends StatelessWidget {
  final String data;
  final double height;
  final Color color;
  final Color background;

  const WaveCode({
    super.key,
    required this.data,
    this.height = 64,
    this.color = AppColors.textCharcoal,
    this.background = AppColors.surfaceCrisp,
  });

  static const int barCount = 23;

  /// Bar heights in 0..1, stable for the same [data].
  static List<double> barsFor(String data) {
    final random = math.Random(data.hashCode);
    return List.generate(barCount, (i) {
      // Fixed anchor bars at both ends and the middle make it look scannable.
      if (i == 0 || i == barCount - 1 || i == barCount ~/ 2) return 0.45;
      return 0.18 + random.nextInt(8) / 9;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bars = barsFor(data);
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.25, vertical: height * 0.16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(height * 0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: height * 0.5,
            height: height * 0.5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.graphic_eq_rounded,
              color: background,
              size: height * 0.32,
            ),
          ),
          SizedBox(width: height * 0.18),
          for (final value in bars) ...[
            Container(
              width: height * 0.07,
              height: (height * 0.68) * value,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            SizedBox(width: height * 0.05),
          ],
        ],
      ),
    );
  }
}
