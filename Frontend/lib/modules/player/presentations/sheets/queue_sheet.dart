import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_bottom_sheet.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../../../common/widgets/pulsing_dot.dart';
import '../../../../core/utils/formatters.dart';
import '../../bloc/player_cubit.dart';
import '../../bloc/player_state.dart';
import '../../models/playing_song_model.dart';

/// SCR-10: Playback queue / Up Next.
class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      title: 'Hàng đợi phát nhạc',
      subtitle: 'Kéo để sắp xếp • Vuốt để xóa',
      expand: true,
      builder: (_) => const QueueSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final cubit = context.read<PlayerCubit>();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _NowPlayingRow(
                song: state.song,
                isPlaying: state.isPlaying,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tiếp theo (${state.queue.length})',
                      style: AppTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (state.queue.isNotEmpty)
                    TextButton(
                      onPressed: cubit.clearQueue,
                      child: Text(
                        'Xóa tất cả',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: state.queue.isEmpty
                  ? _buildEmpty(state.isAutoplay)
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      itemCount: state.queue.length,
                      onReorderItem: cubit.reorderQueue,
                      buildDefaultDragHandles: false,
                      itemBuilder: (context, index) {
                        final song = state.queue[index];
                        return Dismissible(
                          key: ValueKey('${song.id}_$index'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => cubit.removeFromQueue(index),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                            ),
                          ),
                          child: _QueueTile(
                            song: song,
                            index: index,
                            onTap: () => cubit.playFromQueue(index),
                          ),
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCrisp,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.all_inclusive_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tự động phát bài tương tự',
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Autoplay khi hết danh sách',
                            style: AppTextStyles.bodySm,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: state.isAutoplay,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      onChanged: (_) => cubit.toggleAutoplay(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty(bool isAutoplay) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.queue_music_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'Hàng đợi trống',
              style: AppTextStyles.headlineSm,
            ),
            const SizedBox(height: 4),
            Text(
              isAutoplay
                  ? 'Sonara AI sẽ tự động phát bài hát tương tự.'
                  : 'Thêm bài hát từ menu "…" của bất kỳ bài nào.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm,
            ),
          ],
        ),
      ),
    );
  }
}

class _NowPlayingRow extends StatelessWidget {
  final PlayingSongModel song;
  final bool isPlaying;

  const _NowPlayingRow({required this.song, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AppNetworkImage(
            imageUrl: song.coverUrl,
            width: 52,
            height: 52,
            borderRadius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isPlaying) ...[
                      const PulsingDot(size: 5),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      'ĐANG PHÁT',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
          Text(
            Formatters.formatSeconds(song.durationSeconds),
            style: AppTextStyles.bodySm,
          ),
        ],
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  final PlayingSongModel song;
  final int index;
  final VoidCallback onTap;

  const _QueueTile({
    required this.song,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              AppNetworkImage(
                imageUrl: song.coverUrl,
                width: 44,
                height: 44,
                borderRadius: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.formatSeconds(song.durationSeconds),
                style: AppTextStyles.bodySm,
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.drag_handle_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
