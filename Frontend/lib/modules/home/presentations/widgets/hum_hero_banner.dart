import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

/// Compact call-to-action for AI Hum-to-Search: copy on the left, a pulsing
/// mic on the right. The whole card is tappable.
class HumHeroBanner extends StatefulWidget {
  final VoidCallback onHumSearchTap;

  const HumHeroBanner({
    super.key,
    required this.onHumSearchTap,
  });

  @override
  State<HumHeroBanner> createState() => _HumHeroBannerState();
}

class _HumHeroBannerState extends State<HumHeroBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onHumSearchTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngân nga để\ntìm bài hát',
                        style: AppTextStyles.headlineMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Chỉ cần vài giây huýt sáo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Thử ngay',
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _PulsingMic(animation: _pulseController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingMic extends StatelessWidget {
  final Animation<double> animation;

  const _PulsingMic({required this.animation});

  static const double _size = 108;
  static const double _core = 60;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Two staggered rings expanding out of the mic.
              for (final offset in const [0.0, 0.5])
                Builder(
                  builder: (context) {
                    final t = (animation.value + offset) % 1;
                    final diameter = _core + (_size - _core) * t;
                    return Container(
                      width: diameter,
                      height: diameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.18 * (1 - t)),
                      ),
                    );
                  },
                ),
              child!,
            ],
          );
        },
        child: Container(
          width: _core,
          height: _core,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.mic_rounded,
            color: AppColors.primary,
            size: 30,
          ),
        ),
      ),
    );
  }
}
