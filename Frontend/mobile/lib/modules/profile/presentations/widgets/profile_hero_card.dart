import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../models/user_profile_model.dart';

/// Centered identity block: avatar, name, plan, stats and edit button.
class ProfileHeroCard extends StatelessWidget {
  final UserProfileModel profile;
  final VoidCallback onEditProfileTap;
  final VoidCallback? onPlanTap;

  const ProfileHeroCard({
    super.key,
    required this.profile,
    required this.onEditProfileTap,
    this.onPlanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.aiGradient,
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
            child: AppNetworkImage(
              imageUrl: profile.avatarUrl,
              borderRadius: 999,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineMd.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (profile.isVerified) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.verified_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onPlanTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.primary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    profile.vipTier,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _Stat(value: '${profile.listeningHours}', label: 'Giờ nghe'),
            const _StatDivider(),
            _Stat(value: '${profile.humMatchesCount}', label: 'Lần AI Hum'),
            const _StatDivider(),
            _Stat(value: '${profile.playlistsCount}', label: 'Playlist'),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton(
            onPressed: onEditProfileTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textCharcoal,
              side: const BorderSide(color: AppColors.borderMuted),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'Chỉnh sửa hồ sơ',
              style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineSm.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSm,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: AppColors.borderMuted);
  }
}
