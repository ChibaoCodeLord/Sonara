import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/catalog_song_tile.dart';
import '../../../common/widgets/confirm_dialog.dart';
import '../../../common/widgets/sub_page_header.dart';
import '../../../core/routes/app_navigator.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/catalog_song_playback.dart';
import '../../player/presentations/sheets/song_options_sheet.dart';
import '../bloc/downloads_cubit.dart';
import '../bloc/downloads_state.dart';
import '../services/downloads_mock_service.dart';

/// SCR-14: Offline music & download manager.
class OfflineMusicScreen extends StatelessWidget {
  const OfflineMusicScreen({super.key});

  static String formatSize(double mb) =>
      mb >= 1024 ? '${(mb / 1024).toStringAsFixed(1)} GB' : '${mb.round()} MB';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DownloadsCubit(),
      child: BlocBuilder<DownloadsCubit, DownloadsState>(
        builder: (context, state) {
          final cubit = context.read<DownloadsCubit>();
          const hint = 'Ngoại tuyến • Đã tải';
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: Column(
              children: [
                const SubPageHeader(title: 'Nhạc ngoại tuyến'),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    children: [
                      _StorageMeter(state: state),
                      const SizedBox(height: 20),
                      Text(
                        'Chất lượng tải xuống',
                        style: AppTextStyles.headlineSm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _QualityOption(
                            title: '320kbps',
                            subtitle: '~ 8 MB / bài',
                            selected: state.downloadQuality == '320kbps',
                            onTap: () => cubit.setQuality('320kbps'),
                          ),
                          const SizedBox(width: 10),
                          _QualityOption(
                            title: 'FLAC Lossless',
                            subtitle: '~ 35 MB / bài',
                            selected: state.downloadQuality == 'FLAC',
                            onTap: () => cubit.setQuality('FLAC'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCrisp,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Material(
                          type: MaterialType.transparency,
                          child: Column(
                            children: [
                              SwitchListTile(
                                value: state.wifiOnly,
                                onChanged: (_) => cubit.toggleWifiOnly(),
                                activeThumbColor: Colors.white,
                                activeTrackColor: AppColors.primary,
                                secondary: const Icon(
                                  Icons.wifi_rounded,
                                  color: AppColors.primary,
                                ),
                                title: Text(
                                  'Chỉ tải qua Wi-Fi',
                                  style: AppTextStyles.labelLg,
                                ),
                                subtitle: Text(
                                  'Tiết kiệm dữ liệu di động',
                                  style: AppTextStyles.bodySm,
                                ),
                              ),
                              const Divider(
                                height: 1,
                                indent: 72,
                                color: AppColors.borderSubtle,
                              ),
                              SwitchListTile(
                                value: state.autoDownloadLiked,
                                onChanged: (_) =>
                                    cubit.toggleAutoDownloadLiked(),
                                activeThumbColor: Colors.white,
                                activeTrackColor: AppColors.primary,
                                secondary: const Icon(
                                  Icons.favorite_rounded,
                                  color: AppColors.primary,
                                ),
                                title: Text(
                                  'Tự tải bài hát đã thích',
                                  style: AppTextStyles.labelLg,
                                ),
                                subtitle: Text(
                                  'Luôn sẵn sàng khi mất sóng',
                                  style: AppTextStyles.bodySm,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: state.cacheMb == 0
                            ? null
                            : () async {
                                final ok = await showConfirmDialog(
                                  context,
                                  title: 'Xóa bộ nhớ đệm?',
                                  message:
                                      'Giải phóng ${formatSize(state.cacheMb)}. Nhạc đã tải sẽ không bị ảnh hưởng.',
                                  confirmLabel: 'Xóa cache',
                                );
                                if (!ok || !context.mounted) return;
                                cubit.clearCache();
                                AppNavigator.showMessage(
                                  context,
                                  'Đã xóa bộ nhớ đệm',
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.borderMuted),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        icon: const Icon(Icons.cleaning_services_rounded),
                        label: Text(
                          state.cacheMb == 0
                              ? 'Bộ nhớ đệm trống'
                              : 'Xóa bộ nhớ đệm (${formatSize(state.cacheMb)})',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Đã tải (${state.items.length} bài)',
                              style: AppTextStyles.headlineSm.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (state.items.isNotEmpty) ...[
                            IconButton(
                              tooltip: 'Phát tất cả',
                              icon: const Icon(
                                Icons.play_circle_fill_rounded,
                                color: AppColors.primary,
                                size: 32,
                              ),
                              onPressed: () {
                                context.read<PlayerCubit>().playAll(
                                  state.items
                                      .map(
                                        (i) => i.song.toPlayingSong(
                                          contextHint: hint,
                                        ),
                                      )
                                      .toList(),
                                );
                                AppNavigator.openNowPlaying(context);
                              },
                            ),
                            TextButton(
                              onPressed: () async {
                                final ok = await showConfirmDialog(
                                  context,
                                  title: 'Xóa tất cả bản tải?',
                                  message:
                                      'Bạn sẽ cần kết nối mạng để nghe lại các bài hát này.',
                                  confirmLabel: 'Xóa tất cả',
                                );
                                if (ok) cubit.removeAll();
                              },
                              child: Text(
                                'Xóa tất cả',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (state.items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.cloud_download_outlined,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Chưa có bài hát nào được tải',
                                style: AppTextStyles.bodyMd,
                              ),
                            ],
                          ),
                        ),
                      for (final item in state.items)
                        Dismissible(
                          key: ValueKey(item.song.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => cubit.remove(item.song.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          child: CatalogSongTile(
                            song: item.song,
                            trailingText: formatSize(item.sizeMb),
                            badge: Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.quality,
                                style: AppTextStyles.labelSm.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            onTap: () => AppNavigator.playAndOpen(
                              context,
                              item.song.toPlayingSong(contextHint: hint),
                            ),
                            onMoreTap: () => SongOptionsSheet.show(
                              context,
                              item.song.toPlayingSong(contextHint: hint),
                            ),
                          ),
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

class _StorageMeter extends StatelessWidget {
  final DownloadsState state;

  const _StorageMeter({required this.state});

  @override
  Widget build(BuildContext context) {
    const totalMb = DownloadsMockService.deviceTotalGb * 1024;
    const otherMb = DownloadsMockService.otherAppsGb * 1024;
    final freeMb = totalMb - otherMb - state.downloadsMb - state.cacheMb;
    final segments = [
      (state.downloadsMb, AppColors.primary, 'Nhạc đã tải'),
      (state.cacheMb, AppColors.aiGradientEnd, 'Bộ nhớ đệm'),
      (otherMb, AppColors.surfaceDim, 'Ứng dụng khác'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCrisp,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sd_storage_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bộ nhớ thiết bị',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Còn trống ${OfflineMusicScreen.formatSize(freeMb)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  for (final (mb, color, _) in segments)
                    if (mb > 0)
                      Expanded(
                        flex: (mb / totalMb * 1000).round().clamp(8, 1000),
                        child: Container(color: color),
                      ),
                  Expanded(
                    flex: (freeMb / totalMb * 1000).round(),
                    child: Container(color: AppColors.surfaceContainer),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              for (final (mb, color, label) in segments)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$label ${OfflineMusicScreen.formatSize(mb)}',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QualityOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _QualityOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryFixed : AppColors.surfaceCrisp,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderSubtle,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.labelLg.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textCharcoal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 18,
                    color: selected ? AppColors.primary : AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodySm),
            ],
          ),
        ),
      ),
    );
  }
}
