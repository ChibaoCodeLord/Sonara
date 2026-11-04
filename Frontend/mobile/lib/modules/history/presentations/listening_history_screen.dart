import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/catalog_song_tile.dart';
import '../../../common/widgets/confirm_dialog.dart';
import '../../../common/widgets/sub_page_header.dart';
import '../../../core/routes/app_navigator.dart';
import '../../library/bloc/library_cubit.dart';
import '../../player/models/catalog_song_playback.dart';
import '../../player/presentations/sheets/song_options_sheet.dart';
import '../bloc/listening_history_cubit.dart';
import '../models/history_entry_model.dart';
import 'widgets/history_time_format.dart';

/// SCR-15: Recently played timeline grouped by day.
class ListeningHistoryScreen extends StatelessWidget {
  const ListeningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ListeningHistoryCubit(),
      child: BlocBuilder<ListeningHistoryCubit, List<ListeningHistoryEntry>>(
        builder: (context, entries) {
          final cubit = context.read<ListeningHistoryCubit>();
          final groups = <String, List<ListeningHistoryEntry>>{};
          for (final entry in entries) {
            groups
                .putIfAbsent(
                  HistoryTimeFormat.dayLabel(entry.playedAt),
                  () => [],
                )
                .add(entry);
          }

          return Scaffold(
            backgroundColor: AppColors.surface,
            body: Column(
              children: [
                SubPageHeader(
                  title: 'Nghe gần đây',
                  actions: [
                    IconButton(
                      tooltip: 'Lưu thành playlist',
                      icon: const Icon(Icons.playlist_add_rounded),
                      onPressed: entries.isEmpty
                          ? null
                          : () {
                              context.read<LibraryCubit>().createPlaylist(
                                    title: 'Nghe gần đây',
                                    description: 'Tạo từ lịch sử nghe của bạn',
                                    trackCount: entries.length,
                                  );
                              AppNavigator.showMessage(
                                context,
                                'Đã lưu ${entries.length} bài vào playlist mới',
                              );
                            },
                    ),
                    IconButton(
                      tooltip: 'Xóa lịch sử',
                      icon: const Icon(Icons.delete_sweep_outlined),
                      onPressed: entries.isEmpty
                          ? null
                          : () async {
                              final ok = await showConfirmDialog(
                                context,
                                title: 'Xóa lịch sử nghe?',
                                message:
                                    'Toàn bộ lịch sử nghe sẽ bị xóa và không thể khôi phục.',
                                confirmLabel: 'Xóa',
                              );
                              if (ok) cubit.clearAll();
                            },
                    ),
                  ],
                ),
                Expanded(
                  child: entries.isEmpty
                      ? const _EmptyHistory()
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          children: [
                            for (final group in groups.entries) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(4, 16, 4, 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      group.key,
                                      style: AppTextStyles.headlineSm.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${group.value.length} bài',
                                      style: AppTextStyles.bodySm,
                                    ),
                                  ],
                                ),
                              ),
                              for (final entry in group.value)
                                Dismissible(
                                  key: ValueKey(entry.id),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) => cubit.remove(entry.id),
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    color: AppColors.primaryFixed,
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  child: CatalogSongTile(
                                    song: entry.song,
                                    trailingText:
                                        HistoryTimeFormat.clock(entry.playedAt),
                                    onTap: () => AppNavigator.playAndOpen(
                                      context,
                                      entry.song.toPlayingSong(
                                        contextHint: 'Lịch sử • ${entry.source}',
                                      ),
                                    ),
                                    onMoreTap: () => SongOptionsSheet.show(
                                      context,
                                      entry.song.toPlayingSong(),
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_rounded,
              size: 52,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text('Chưa có lịch sử nghe', style: AppTextStyles.headlineSm),
            const SizedBox(height: 4),
            Text(
              'Những bài hát bạn nghe sẽ xuất hiện ở đây.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm,
            ),
          ],
        ),
      ),
    );
  }
}
