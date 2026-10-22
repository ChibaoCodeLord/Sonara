import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../core/routes/app_navigator.dart';
import '../../../../core/routes/app_router.dart';
import '../../bloc/player_state.dart';
import '../sheets/queue_sheet.dart';
import '../sheets/share_song_sheet.dart';
import '../sheets/sleep_timer_sheet.dart';

/// Secondary Now Playing actions: queue, sleep timer, EQ and share.
class PlayerUtilityRow extends StatelessWidget {
  final PlayerState state;

  const PlayerUtilityRow({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final sleepLabel = state.sleepRemaining != null
        ? SleepTimerSheet.formatRemaining(state.sleepRemaining!)
        : state.sleepAfterCurrentTrack
            ? 'Hết bài'
            : 'Hẹn giờ';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _UtilityButton(
          icon: Icons.queue_music_rounded,
          label: state.queue.isEmpty
              ? 'Hàng đợi'
              : 'Tiếp theo (${state.queue.length})',
          onTap: () => QueueSheet.show(context),
        ),
        _UtilityButton(
          icon: state.hasSleepTimer
              ? Icons.bedtime_rounded
              : Icons.bedtime_outlined,
          label: sleepLabel,
          isActive: state.hasSleepTimer,
          onTap: () => SleepTimerSheet.show(context),
        ),
        _UtilityButton(
          icon: Icons.equalizer_rounded,
          label: 'Equalizer',
          onTap: () => AppNavigator.push(context, AppRouter.equalizer),
        ),
        _UtilityButton(
          icon: Icons.ios_share_rounded,
          label: 'Chia sẻ',
          onTap: () => ShareSongSheet.show(
            context,
            id: state.song.id,
            title: state.song.title,
            subtitle: state.song.artist,
            coverUrl: state.song.coverUrl,
          ),
        ),
      ],
    );
  }
}

class _UtilityButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _UtilityButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
