import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_bottom_sheet.dart';
import '../../bloc/player_cubit.dart';
import '../../bloc/player_state.dart';

/// SCR-13: Sleep timer bottom sheet.
class SleepTimerSheet extends StatelessWidget {
  const SleepTimerSheet({super.key});

  static const _options = [
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 45),
    Duration(hours: 1),
  ];

  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      title: 'Hẹn giờ tắt nhạc',
      subtitle: 'Sonara sẽ tự dừng phát khi bạn đã ngủ',
      builder: (_) => const SleepTimerSheet(),
    );
  }

  static String formatRemaining(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String _label(Duration d) =>
      d.inMinutes >= 60 ? '${d.inHours} giờ' : '${d.inMinutes} phút';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final cubit = context.read<PlayerCubit>();
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 28),
          child: Column(
            children: [
              if (state.hasSleepTimer) _buildCountdown(state),
              for (final option in _options)
                SheetActionTile(
                  icon: Icons.bedtime_outlined,
                  label: _label(option),
                  onTap: () {
                    cubit.startSleepTimer(option);
                    Navigator.of(context).pop();
                  },
                ),
              SheetActionTile(
                icon: Icons.music_off_rounded,
                label: 'Sau khi hết bài hát này',
                subtitle: state.song.title,
                trailing: state.sleepAfterCurrentTrack
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  cubit.sleepAfterCurrentTrack();
                  Navigator.of(context).pop();
                },
              ),
              if (state.hasSleepTimer)
                SheetActionTile(
                  icon: Icons.timer_off_outlined,
                  color: AppColors.primary,
                  label: 'Tắt hẹn giờ',
                  onTap: () {
                    cubit.cancelSleepTimer();
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdown(PlayerState state) {
    final remaining = state.sleepRemaining;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: remaining == null
                      ? null
                      : (remaining.inSeconds % 60) / 60,
                  strokeWidth: 4,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
                const Icon(Icons.nightlight_round, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhạc sẽ dừng sau',
                  style: AppTextStyles.labelMd.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  remaining == null
                      ? 'Hết bài hiện tại'
                      : formatRemaining(remaining),
                  style: AppTextStyles.headlineLg.copyWith(
                    color: Colors.white,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
