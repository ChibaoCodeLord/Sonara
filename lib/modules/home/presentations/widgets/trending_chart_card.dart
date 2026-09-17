import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../models/chart_track_model.dart';

class TrendingChartCard extends StatelessWidget {
  final List<ChartTrackModel> charts;
  final bool isWeekly;
  final ValueChanged<bool>? onTimeframeChanged;
  final Function(ChartTrackModel)? onTrackTap;

  const TrendingChartCard({
    super.key,
    required this.charts,
    this.isWeekly = true,
    this.onTimeframeChanged,
    this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Timeframe toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CẬP NHẬT MỖI NGÀY',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bảng Xếp Hạng Xu Hướng',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            // Segmented pill: Tuần / Tháng
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildPillTab('Tuần', isWeekly, () => onTimeframeChanged?.call(true)),
                  _buildPillTab('Tháng', !isWeekly, () => onTimeframeChanged?.call(false)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // White Card containing the chart rows
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCrisp,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: charts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = charts[index];
              return _buildChartRow(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPillTab(String title, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceCrisp : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: AppTextStyles.labelSm.copyWith(
            color: selected ? AppColors.textCharcoal : AppColors.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChartRow(ChartTrackModel item) {
    Color rankColor;
    if (item.rank == '01') {
      rankColor = AppColors.aiGradientEnd;
    } else if (item.rank == '02') {
      rankColor = AppColors.primary;
    } else if (item.rank == '03') {
      rankColor = AppColors.aiGradientStart;
    } else {
      rankColor = AppColors.textMuted;
    }

    return GestureDetector(
      onTap: () => onTrackTap?.call(item),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 32,
            child: Text(
              item.rank,
              style: AppTextStyles.headlineMd.copyWith(
                color: rankColor,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Cover Art
          SizedBox(
            width: 44,
            height: 44,
            child: AppNetworkImage(
              imageUrl: item.imageUrl,
              borderRadius: 8,
            ),
          ),
          const SizedBox(width: 12),
          // Title & Artist & Delta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.borderMuted,
                      ),
                    ),
                    _buildDeltaBadge(item.rankDelta),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Plays
          Text(
            item.plays,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeltaBadge(int delta) {
    if (delta > 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_drop_up_rounded,
            color: AppColors.primary,
            size: 16,
          ),
          Text(
            '+$delta',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    } else if (delta < 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_drop_down_rounded,
            color: Colors.orange,
            size: 16,
          ),
          Text(
            '$delta',
            style: AppTextStyles.labelSm.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.remove_rounded,
            color: AppColors.textMuted,
            size: 14,
          ),
          Text(
            '0',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
  }
}
