import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../models/recent_hum_history_model.dart';

class AiHumHistoryCard extends StatefulWidget {
  final RecentHumHistoryModel recentHum;
  final int totalCount;
  final VoidCallback onPlayTap;
  final VoidCallback? onTap;

  const AiHumHistoryCard({
    super.key,
    required this.recentHum,
    required this.totalCount,
    required this.onPlayTap,
    this.onTap,
  });

  @override
  State<AiHumHistoryCard> createState() => _AiHumHistoryCardState();
}

class _AiHumHistoryCardState extends State<AiHumHistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
        color: AppColors.surfaceCrisp,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.aiGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch sử tìm bằng AI',
                      style: AppTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Nhận diện tiếng ngâm nga & huýt sáo',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${widget.totalCount} giai điệu',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Recent Match Preview Banner
          GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  // Artwork
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AppNetworkImage(
                        imageUrl: widget.recentHum.coverUrl,
                        width: 48,
                        height: 48,
                        borderRadius: 8,
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Song details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.recentHum.title,
                                style: AppTextStyles.labelMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${widget.recentHum.matchPercentage} Khớp',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.recentHum.artist} • ${widget.recentHum.timeAgo}',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Soundwave visualizer
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, _) {
                      final val = _animController.value;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildWaveBar(8 + val * 6, AppColors.primary),
                          const SizedBox(width: 2.5),
                          _buildWaveBar(16 - val * 8, AppColors.aiGradientEnd),
                          const SizedBox(width: 2.5),
                          _buildWaveBar(12 + val * 5, AppColors.primary),
                          const SizedBox(width: 2.5),
                          _buildWaveBar(6 + val * 8, AppColors.aiGradientEnd),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 10),

                  // Play button
                  GestureDetector(
                    onTap: widget.onPlayTap,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceCrisp,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBar(double height, Color color) {
    return Container(
      width: 2.5,
      height: height.clamp(4, 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
