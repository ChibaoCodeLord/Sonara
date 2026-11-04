import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_bottom_sheet.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../../../common/widgets/wave_code.dart';
import '../../../../core/routes/app_navigator.dart';

/// Share card for a song, playlist or album with its Sonara Wave Code.
class ShareSongSheet extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String coverUrl;

  const ShareSongSheet({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coverUrl,
  });

  static Future<void> show(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required String coverUrl,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      title: 'Chia sẻ',
      subtitle: 'Bạn bè có thể quét Wave Code để nghe ngay',
      builder: (_) => ShareSongSheet(
        id: id,
        title: title,
        subtitle: subtitle,
        coverUrl: coverUrl,
      ),
    );
  }

  String get _link => 'https://sonara.vn/s/$id';

  @override
  Widget build(BuildContext context) {
    const targets = [
      (Icons.auto_stories_rounded, 'Instagram Story'),
      (Icons.facebook_rounded, 'Facebook'),
      (Icons.music_video_rounded, 'TikTok'),
      (Icons.chat_bubble_rounded, 'Messenger'),
      (Icons.qr_code_2_rounded, 'Zalo'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                AppNetworkImage(
                  imageUrl: coverUrl,
                  width: 150,
                  height: 150,
                  borderRadius: 18,
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineSm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                WaveCode(
                  data: id,
                  height: 52,
                  color: AppColors.primary,
                  background: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: targets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final (icon, label) = targets[index];
                return GestureDetector(
                  onTap: () {
                    AppNavigator.showMessage(context, 'Đang mở $label...');
                    Navigator.of(context).pop();
                  },
                  child: SizedBox(
                    width: 68,
                    child: Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCrisp,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Icon(icon, color: AppColors.primary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.textCharcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(left: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCrisp,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _link,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMd,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _link));
                    AppNavigator.showMessage(context, 'Đã sao chép liên kết');
                  },
                  child: Text(
                    'Sao chép',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.primary,
                    ),
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
