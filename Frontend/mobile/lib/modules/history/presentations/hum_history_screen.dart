import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/confirm_dialog.dart';
import '../../../common/widgets/sub_page_header.dart';
import '../../../core/routes/app_navigator.dart';
import '../../player/models/catalog_song_playback.dart';
import '../bloc/hum_history_cubit.dart';
import '../models/history_entry_model.dart';
import 'widgets/history_time_format.dart';

/// Every song recognised through AI Hum-to-Search.
class HumHistoryScreen extends StatelessWidget {
  const HumHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HumHistoryCubit(),
      child: BlocBuilder<HumHistoryCubit, HumHistoryState>(
        builder: (context, state) {
          final cubit = context.read<HumHistoryCubit>();
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: Column(
              children: [
                SubPageHeader(
                  title: 'Lịch sử AI Hum',
                  actions: [
                    IconButton(
                      tooltip: 'Xóa tất cả',
                      icon: const Icon(Icons.delete_sweep_outlined),
                      onPressed: state.entries.isEmpty
                          ? null
                          : () async {
                              final ok = await showConfirmDialog(
                                context,
                                title: 'Xóa lịch sử nhận diện?',
                                message:
                                    'Các bản ghi âm và kết quả nhận diện sẽ bị xóa vĩnh viễn.',
                                confirmLabel: 'Xóa',
                              );
                              if (ok) cubit.clearAll();
                            },
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    children: [
                      _StatsCard(state: state),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (key, label) in const [
                            ('all', 'Tất cả'),
                            ('hum', 'Ngân nga'),
                            ('whistle', 'Huýt sáo'),
                          ]) ...[
                            ChoiceChip(
                              label: Text(label),
                              selected: state.filter == key,
                              showCheckmark: false,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surfaceCrisp,
                              side: const BorderSide(
                                color: AppColors.borderMuted,
                              ),
                              labelStyle: AppTextStyles.labelMd.copyWith(
                                color: state.filter == key
                                    ? Colors.white
                                    : AppColors.textCharcoal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              onSelected: (_) => cubit.setFilter(key),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.visible.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.graphic_eq_rounded,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Chưa có bản ghi nào',
                                style: AppTextStyles.headlineSm,
                              ),
                            ],
                          ),
                        ),
                      for (final entry in state.visible)
                        Dismissible(
                          key: ValueKey(entry.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => cubit.remove(entry.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          child: _HumEntryTile(entry: entry),
                        ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => AppNavigator.openHumSearch(context),
                        icon: const Icon(Icons.mic_rounded),
                        label: const Text('Ngân nga tìm bài mới'),
                      ),
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

class _StatsCard extends StatelessWidget {
  final HumHistoryState state;

  const _StatsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final whistles = state.entries.where((e) => e.mode == 'whistle').length;
    Widget stat(String value, String label) => Expanded(
          child: Column(
            children: [
              Text(
                value,
                style: AppTextStyles.headlineMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(color: Colors.white70),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          stat('${state.entries.length}', 'Lần nhận diện'),
          stat('${state.averageMatch}%', 'Độ khớp TB'),
          stat('$whistles', 'Lần huýt sáo'),
        ],
      ),
    );
  }
}

class _HumEntryTile extends StatelessWidget {
  final HumHistoryEntry entry;

  const _HumEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AppNavigator.playAndOpen(
        context,
        entry.song.toPlayingSong(
          contextHint: 'AI Hum Match (${entry.matchPercentage}%)',
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCrisp,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            AppNetworkImage(
              imageUrl: entry.song.coverUrl,
              width: 52,
              height: 52,
              borderRadius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    entry.song.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        entry.mode == 'whistle'
                            ? Icons.air_rounded
                            : Icons.mic_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '${entry.modeLabel} ${entry.recordSeconds}s • ${HistoryTimeFormat.timeAgo(entry.recordedAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSm,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: entry.matchPercentage >= 90
                    ? AppColors.primaryFixed
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${entry.matchPercentage}%',
                style: AppTextStyles.labelMd.copyWith(
                  color: entry.matchPercentage >= 90
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
