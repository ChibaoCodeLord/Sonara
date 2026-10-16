import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

class PlaylistMetaInfo extends StatelessWidget {
  final String title;
  final String engineTag;
  final String description;

  const PlaylistMetaInfo({
    super.key,
    required this.title,
    required this.engineTag,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              engineTag,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
