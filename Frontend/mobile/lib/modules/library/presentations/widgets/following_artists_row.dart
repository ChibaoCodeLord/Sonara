import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';
import '../../../../common/widgets/section_title.dart';
import '../../models/following_artist_model.dart';

class FollowingArtistsRow extends StatelessWidget {
  final List<FollowingArtistModel> artists;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<FollowingArtistModel>? onArtistTap;
  final VoidCallback onAddArtistTap;

  const FollowingArtistsRow({
    super.key,
    required this.artists,
    this.onSeeAllTap,
    this.onArtistTap,
    required this.onAddArtistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Nghệ sĩ',
          actionLabel: onSeeAllTap == null ? null : 'Xem tất cả',
          onActionTap: onSeeAllTap,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: artists.length + 1, // +1 for "Thêm"
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              if (index == artists.length) {
                return _ArtistBubble(
                  label: 'Thêm',
                  onTap: onAddArtistTap,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderMuted),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              }
              final artist = artists[index];
              return _ArtistBubble(
                label: artist.name,
                onTap: () => onArtistTap?.call(artist),
                child: AppNetworkImage(
                  imageUrl: artist.avatarUrl,
                  borderRadius: 999,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ArtistBubble extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Widget child;

  const _ArtistBubble({
    required this.label,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            SizedBox(width: 64, height: 64, child: child),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.textCharcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
