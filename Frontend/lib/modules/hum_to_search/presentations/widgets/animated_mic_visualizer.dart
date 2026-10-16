import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';

class AnimatedMicVisualizer extends StatefulWidget {
  final VoidCallback? onMicTap;

  const AnimatedMicVisualizer({
    super.key,
    this.onMicTap,
  });

  @override
  State<AnimatedMicVisualizer> createState() => _AnimatedMicVisualizerState();
}

class _AnimatedMicVisualizerState extends State<AnimatedMicVisualizer>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _eqController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Concentric pulsing rings controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Fast dynamic bouncing EQ bars controller
    _eqController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _eqController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ambient pulse background layer
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.aiGradientStart.withValues(alpha: 0.18),
                      AppColors.aiGradientEnd.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Animated Pulsing Sound Rings
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final v1 = _pulseController.value;
                  final v2 = (_pulseController.value + 0.35) % 1.0;
                  final v3 = (_pulseController.value + 0.7) % 1.0;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildPulseRing(180 + v1 * 90, 0.28 * (1 - v1)),
                      _buildPulseRing(160 + v2 * 80, 0.32 * (1 - v2)),
                      _buildPulseRing(140 + v3 * 60, 0.38 * (1 - v3)),
                    ],
                  );
                },
              ),

              // Central Interactive Glowing Mic Core
              GestureDetector(
                onTap: widget.onMicTap,
                child: Container(
                  width: 124,
                  height: 124,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.aiGradient,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x61B3122E),
                        blurRadius: 36,
                        offset: Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Color(0x40FF4B4B),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryContainer,
                          AppColors.aiGradientEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glass highlight
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.25),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.mic_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Active Audio Waveform Equalizer (Dynamic 19 Bars)
        AnimatedBuilder(
          animation: _eqController,
          builder: (context, child) {
            return SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(19, (index) {
                  // Generate oscillating bar heights
                  final baseHeights = [
                    8.0, 16.0, 28.0, 12.0, 36.0, 44.0, 24.0, 40.0, 48.0,
                    32.0, 20.0, 40.0, 48.0, 28.0, 44.0, 16.0, 32.0, 20.0, 8.0
                  ];
                  final jitter = (_random.nextDouble() * 12) - 6;
                  final height = (baseHeights[index] + jitter).clamp(6.0, 48.0);

                  return Container(
                    width: 3.5,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 2.2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.aiGradientStart,
                          AppColors.aiGradientEnd,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPulseRing(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: opacity.clamp(0.0, 1.0)),
      ),
    );
  }
}
