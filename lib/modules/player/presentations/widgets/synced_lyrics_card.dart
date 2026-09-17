import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../models/lyric_line_model.dart';

class SyncedLyricsCard extends StatefulWidget {
  final List<LyricLineModel> lyrics;
  final VoidCallback? onFullScreenTap;

  const SyncedLyricsCard({
    super.key,
    required this.lyrics,
    this.onFullScreenTap,
  });

  @override
  State<SyncedLyricsCard> createState() => _SyncedLyricsCardState();
}

class _SyncedLyricsCardState extends State<SyncedLyricsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCrisp,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lyrics_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lời bài hát đồng bộ',
                    style: AppTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: widget.onFullScreenTap ?? () {},
                child: Row(
                  children: [
                    Text(
                      'Toàn màn hình',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.open_in_full_rounded,
                      color: AppColors.primary,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Synced Lines
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.lyrics.map((line) {
              if (line.isCurrent) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    line.text,
                    style: AppTextStyles.headlineSm.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  line.text,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textMuted.withValues(alpha: 0.65),
                    height: 1.4,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Acoustic Waveform Glow Indicator
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              final v = _waveController.value;
              return Row(
                children: [
                  _buildWaveBar(4 + v * 8, AppColors.primary.withValues(alpha: 0.4)),
                  _buildWaveBar(12 - v * 6, AppColors.primary),
                  _buildWaveBar(8 + v * 4, AppColors.primary.withValues(alpha: 0.8)),
                  _buildWaveBar(4 - v * 2, AppColors.primary.withValues(alpha: 0.3)),
                  _buildWaveBar(10 + v * 4, AppColors.primary.withValues(alpha: 0.6)),
                  _buildWaveBar(12 - v * 7, AppColors.primary),
                  _buildWaveBar(5 + v * 6, AppColors.primary.withValues(alpha: 0.4)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBar(double height, Color color) {
    return Container(
      width: 4,
      height: height.clamp(3.0, 14.0),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
