import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Sonara brand mark: a round badge with the "S-Wave" glyph
/// (an S flanked by sound-wave bars). Matches the launcher icon.
class SonaraLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const SonaraLogo({super.key, this.size = 32, this.showShadow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x33B3122E),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        size: Size.square(size),
        painter: const _SonaraLogoPainter(),
      ),
    );
  }
}

class _SonaraLogoPainter extends CustomPainter {
  const _SonaraLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn in a 100x100 design grid.
    final unit = size.width / 100;
    canvas.scale(unit);

    canvas.drawCircle(
      const Offset(50, 50),
      50,
      Paint()..color = AppColors.primaryContainer,
    );

    // Glyph sits at 88% of the badge, centred.
    canvas.translate(6, 6);
    canvas.scale(0.88);

    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final s = Path()
      ..moveTo(58.66, 35)
      ..arcToPoint(
        const Offset(50, 50),
        radius: const Radius.circular(10),
        largeArc: true,
        clockwise: false,
      )
      ..arcToPoint(
        const Offset(41.34, 65),
        radius: const Radius.circular(10),
        largeArc: true,
      );
    canvas.drawPath(s, stroke..strokeWidth = 8);

    stroke.strokeWidth = 6.5;
    const bars = [
      (17.0, 45.0, 55.0),
      (27.0, 39.0, 61.0),
      (73.0, 39.0, 61.0),
      (83.0, 45.0, 55.0),
    ];
    for (final (x, top, bottom) in bars) {
      canvas.drawLine(Offset(x, top), Offset(x, bottom), stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _SonaraLogoPainter oldDelegate) => false;
}
