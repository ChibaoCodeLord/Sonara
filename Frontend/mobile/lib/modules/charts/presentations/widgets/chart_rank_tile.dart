import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../models/chart_item_model.dart';

/// One flat chart row: rank + movement, cover, title/artist, play.
///
/// Rows are meant to sit inside a shared card separated by dividers.
class ChartRankTile extends StatelessWidget {
  final ChartItemModel item;
  final VoidCallback onPlayTap;
  final VoidCallback? onTap;

  const ChartRankTile({
    super.key,
    required this.item,
    required this.onPlayTap,
    this.onTap,
  });

  bool get _isTop3 => (int.tryParse(item.rank) ?? 99) <= 3;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? onPlayTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 4, 10),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.rank,
                    style: AppTextStyles.headlineSm.copyWith(
                      color: _isTop3 ? AppColors.primary : AppColors.textCharcoal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  _RankDelta(delta: item.rankDelta),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppNetworkImage(
              imageUrl: item.imageUrl,
              width: 52,
              height: 52,
              borderRadius: 10,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (item.isHumHot) ...[
                        const SizedBox(width: 6),
                        const Tooltip(
                          message: 'Được ngân nga nhiều',
                          child: Icon(
                            Icons.graphic_eq_rounded,
                            color: AppColors.primary,
                            size: 15,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.artist} • ${item.playsText}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Phát',
              onPressed: onPlayTap,
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.textCharcoal,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankDelta extends StatelessWidget {
  final int delta;

  const _RankDelta({required this.delta});

  @override
  Widget build(BuildContext context) {
    if (delta == 0) {
      return const Icon(Icons.remove_rounded, size: 12, color: AppColors.textMuted);
    }
    final isUp = delta > 0;
    final color = isUp ? AppColors.emeraldActive : AppColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
          size: 16,
          color: color,
        ),
        Text(
          '${delta.abs()}',
          style: AppTextStyles.labelSm.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
