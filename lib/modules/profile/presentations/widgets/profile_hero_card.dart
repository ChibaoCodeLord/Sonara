import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../../../common/widgets/pulsing_dot.dart';
import '../../models/user_profile_model.dart';

class ProfileHeroCard extends StatelessWidget {
  final UserProfileModel profile;
  final VoidCallback onEditProfileTap;

  const ProfileHeroCard({
    super.key,
    required this.profile,
    required this.onEditProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCrisp,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1A1A1A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section: Avatar & user information
          Row(
            children: [
              // Avatar with gradient border & star badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.aiGradient,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33B3122E),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AppNetworkImage(
                      imageUrl: profile.avatarUrl,
                      width: 72,
                      height: 72,
                      borderRadius: 999,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x29000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Name, VIP pill & edit button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile.name,
                          style: AppTextStyles.headlineSm.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (profile.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // VIP Lossless pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PulsingDot(
                            color: AppColors.primary,
                            size: 6,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            profile.vipTier.toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Edit profile button
                    GestureDetector(
                      onTap: onEditProfileTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.tune_rounded,
                              color: AppColors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Chỉnh sửa hồ sơ',
                              style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.textCharcoal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Acoustic Listening Stats (3 cols)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    value: '${profile.listeningHours}',
                    label: 'Giờ nghe',
                    isPrimaryColor: true,
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: AppColors.borderSubtle,
                ),
                Expanded(
                  child: _buildStatItem(
                    value: '${profile.humMatchesCount}',
                    label: 'Hum AI Match',
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: AppColors.borderSubtle,
                ),
                Expanded(
                  child: _buildStatItem(
                    value: '${profile.playlistsCount}',
                    label: 'Playlists',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    bool isPrimaryColor = false,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineSm.copyWith(
            color: isPrimaryColor ? AppColors.primary : AppColors.textCharcoal,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
