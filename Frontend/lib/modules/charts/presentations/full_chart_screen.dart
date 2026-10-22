import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/sub_page_header.dart';
import '../../../core/routes/app_navigator.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/playing_song_model.dart';
import '../models/chart_item_model.dart';
import '../services/charts_mock_service.dart';
import 'widgets/chart_rank_tile.dart';

/// Full Top 50 chart behind "Xem tất cả" on the Charts tab.
class FullChartScreen extends StatefulWidget {
  final String initialTab; // 'vn' | 'global'

  const FullChartScreen({super.key, this.initialTab = 'vn'});

  @override
  State<FullChartScreen> createState() => _FullChartScreenState();
}

class _FullChartScreenState extends State<FullChartScreen> {
  final _service = ChartsMockService();
  late String _tab = widget.initialTab;
  late List<ChartItemModel> _items = _service.getFullChart(_tab);

  void _switchTab(String tab) {
    if (tab == _tab) return;
    setState(() {
      _tab = tab;
      _items = _service.getFullChart(tab);
    });
  }

  PlayingSongModel _toSong(ChartItemModel item) {
    return PlayingSongModel(
      id: 'chart_${_tab}_${item.rank}',
      title: item.title,
      artist: item.artist,
      coverUrl: item.imageUrl,
      durationSeconds: 228,
      currentSeconds: 0,
      contextHint: _tab == 'vn'
          ? 'Việt Nam Hot 50 • #${item.rank}'
          : 'Quốc Tế Viral 50 • #${item.rank}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _tab == 'vn' ? 'Việt Nam Hot 50' : 'Quốc Tế Viral 50';
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          SubPageHeader(title: title),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: _items.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) return _buildHeader(context);
                final item = _items[index - 1];
                return ChartRankTile(
                  item: item,
                  onTap: () => AppNavigator.playAndOpen(context, _toSong(item)),
                  onPlayTap: () =>
                      context.read<PlayerCubit>().playSong(_toSong(item)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    Widget tabButton(String key, String label) {
      final selected = _tab == key;
      return Expanded(
        child: GestureDetector(
          onTap: () => _switchTab(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.surfaceCrisp : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelLg.copyWith(
                color: selected ? AppColors.primary : AppColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              tabButton('vn', 'Việt Nam Hot 50'),
              tabButton('global', 'Quốc Tế Viral'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                'Cập nhật mỗi ngày lúc 00:00 • Dựa trên lượt nghe & lượt AI Hum',
                style: AppTextStyles.bodySm,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                context
                    .read<PlayerCubit>()
                    .playAll(_items.map(_toSong).toList());
                AppNavigator.openNowPlaying(context);
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Phát tất cả'),
            ),
          ],
        ),
      ],
    );
  }
}
