import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../models/following_artist_model.dart';

class FollowingArtistsRow extends StatelessWidget {
  final List<FollowingArtistModel> artists;
  final VoidCallback onSeeAllTap;
  final ValueChanged<FollowingArtistModel>? onArtistTap;
  final VoidCallback onAddArtistTap;

  const FollowingArtistsRow({
    super.key,
    required this.artists,
    required this.onSeeAllTap,
    this.onArtistTap,
    required this.onAddArtistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Nghệ sĩ đang theo dõi',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '5 mới',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onSeeAllTap,
              child: Text(
                'Xem tất cả',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal artist avatar list
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: artists.length + 1, // +1 for "Thêm"
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              if (index < artists.length) {
                final artist = artists[index];
                return GestureDetector(
                  onTap: () => onArtistTap?.call(artist),
                  child: SizedBox(
                    width: 64,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x12000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: AppNetworkImage(
                                imageUrl: artist.avatarUrl,
                                width: 64,
                                height: 64,
                                borderRadius: 999,
                              ),
                            ),
                            if (artist.isVerified)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 11,
                                  ),
                                ),
                              ),
                            if (artist.hasNewUpdate)
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.aiGradientEnd,
                                    border: Border.all(
                                      color: AppColors.surfaceCrisp,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          artist.name,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.textCharcoal,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // "Thêm" button item
              return GestureDetector(
                onTap: onAddArtistTap,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainer,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppColors.textMuted,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Thêm',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
