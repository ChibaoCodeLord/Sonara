import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../models/spotlight_radar_model.dart';

class SpotlightRadarCard extends StatefulWidget {
  final SpotlightRadarModel spotlight;
  final VoidCallback onPlayTap;

  const SpotlightRadarCard({
    super.key,
    required this.spotlight,
    required this.onPlayTap,
  });

  @override
  State<SpotlightRadarCard> createState() => _SpotlightRadarCardState();
}

class _SpotlightRadarCardState extends State<SpotlightRadarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x52B3122E),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Ambient soundwave blur glow
            Positioned(
              right: -16,
              bottom: -16,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top row: Badge & growth info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.sensors_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI RADAR TUẦN NÀY',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          widget.spotlight.growthText,
                          style: AppTextStyles.labelSm.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Bottom row: Cover, Title, Visualizer & Play Button
                  Row(
                    children: [
                      // Cover with Hum #1 badge
                      Stack(
                        children: [
                          AppNetworkImage(
                            imageUrl: widget.spotlight.coverUrl,
                            width: 64,
                            height: 64,
                            borderRadius: 12,
                          ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'HUM #1',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Details & Visualizer
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.spotlight.title,
                              style: AppTextStyles.headlineSm.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.spotlight.artist} • ${widget.spotlight.humCountText}',
                              style: AppTextStyles.bodySm.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            // Mini Waveform & accuracy rate
                            AnimatedBuilder(
                              animation: _animController,
                              builder: (context, _) {
                                final val = _animController.value;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _buildWaveBar(6 + val * 6),
                                    const SizedBox(width: 2.5),
                                    _buildWaveBar(14 - val * 7),
                                    const SizedBox(width: 2.5),
                                    _buildWaveBar(18 - val * 9),
                                    const SizedBox(width: 2.5),
                                    _buildWaveBar(8 + val * 8),
                                    const SizedBox(width: 2.5),
                                    _buildWaveBar(12 - val * 5),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.spotlight.matchRateText,
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Play button
                      GestureDetector(
                        onTap: widget.onPlayTap,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceCrisp,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x2B000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveBar(double height) {
    return Container(
      width: 2.5,
      height: height.clamp(4, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
