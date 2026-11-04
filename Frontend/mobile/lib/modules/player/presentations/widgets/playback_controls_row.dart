import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';

class PlaybackControlsRow extends StatelessWidget {
  final bool isPlaying;
  final bool isShuffle;
  final bool isRepeat;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onShuffleToggle;
  final VoidCallback onRepeatToggle;

  const PlaybackControlsRow({
    super.key,
    required this.isPlaying,
    required this.isShuffle,
    required this.isRepeat,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onShuffleToggle,
    required this.onRepeatToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Shuffle
        IconButton(
          icon: Icon(
            Icons.shuffle_rounded,
            color: isShuffle ? AppColors.primary : AppColors.textMuted,
            size: 24,
          ),
          onPressed: onShuffleToggle,
        ),
        // Previous
        IconButton(
          icon: const Icon(
            Icons.skip_previous_rounded,
            color: AppColors.textCharcoal,
            size: 36,
          ),
          onPressed: onPrevious,
        ),
        // Center 68px Gradient Play/Pause Button
        GestureDetector(
          onTap: onPlayPause,
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.aiGradient,
              boxShadow: const [
                BoxShadow(
                  color: AppColors.waveformGlow,
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ),
        // Next
        IconButton(
          icon: const Icon(
            Icons.skip_next_rounded,
            color: AppColors.textCharcoal,
            size: 36,
          ),
          onPressed: onNext,
        ),
        // Repeat
        IconButton(
          icon: Icon(
            Icons.repeat_rounded,
            color: isRepeat ? AppColors.primary : AppColors.textMuted,
            size: 24,
          ),
          onPressed: onRepeatToggle,
        ),
      ],
    );
  }
}
