import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../models/playing_song_model.dart';

class MiniPlayerBar extends StatefulWidget {
  final PlayingSongModel song;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayPauseTap;
  final VoidCallback onNextTap;

  const MiniPlayerBar({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayPauseTap,
    required this.onNextTap,
  });

  @override
  State<MiniPlayerBar> createState() => _MiniPlayerBarState();
}

class _MiniPlayerBarState extends State<MiniPlayerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.song.durationSeconds > 0
        ? (widget.song.currentSeconds / widget.song.durationSeconds).clamp(0.0, 1.0)
        : 0.42;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCrisp,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.borderSubtle.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A1A1A14),
              blurRadius: 24,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Progress Line
              Container(
                height: 2.5,
                width: double.infinity,
                color: AppColors.borderSubtle,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.miniPlayerProgressGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Bar Contents
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    // Thumbnail
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.song.coverUrl.isNotEmpty
                            ? AppNetworkImage(
                                imageUrl: widget.song.coverUrl,
                                borderRadius: 12,
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.heroGradient,
                                ),
                                child: const Center(
                                  child: Text(
                                    '♪',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title & Artist with dynamic soundwave
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.song.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (widget.isPlaying)
                                AnimatedBuilder(
                                  animation: _waveController,
                                  builder: (context, child) {
                                    final v = _waveController.value;
                                    return Row(
                                      children: [
                                        _buildMiniWaveBar(6 + v * 6, AppColors.primary),
                                        _buildMiniWaveBar(12 - v * 8, AppColors.aiGradientEnd),
                                        _buildMiniWaveBar(8 + v * 5, AppColors.primary),
                                      ],
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Actions: Play/Pause and Skip Next
                    IconButton(
                      icon: Icon(
                        widget.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      onPressed: widget.onPlayPauseTap,
                      splashRadius: 22,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.textMuted,
                        size: 26,
                      ),
                      onPressed: widget.onNextTap,
                      splashRadius: 22,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniWaveBar(double height, Color color) {
    return Container(
      width: 2.2,
      height: height.clamp(4.0, 14.0),
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
