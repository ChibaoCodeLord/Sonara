import 'package:flutter/material.dart';
import '../../core/catalog/catalog_models.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'app_network_image.dart';

/// Compact song row used by search, artist, album, history and mood pages.
class CatalogSongTile extends StatelessWidget {
  final CatalogSong song;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;
  final int? index;
  final String? trailingText;
  final bool showCover;
  final bool isActive;
  final Widget? badge;

  const CatalogSongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onMoreTap,
    this.index,
    this.trailingText,
    this.showCover = true,
    this.isActive = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            if (index != null) ...[
              SizedBox(
                width: 26,
                child: Text(
                  index!.toString().padLeft(2, '0'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMd.copyWith(
                    color: isActive ? AppColors.primary : AppColors.textMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (showCover) ...[
              AppNetworkImage(
                imageUrl: song.coverUrl,
                width: 48,
                height: 48,
                borderRadius: 10,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelLg.copyWith(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textCharcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (song.isExplicit) ...[
                        const SizedBox(width: 6),
                        const _ExplicitBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${song.quality}  ',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(text: song.artistName),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ?badge,
            if (trailingText != null) ...[
              const SizedBox(width: 8),
              Text(
                trailingText!,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
            if (onMoreTap != null)
              IconButton(
                tooltip: 'Tùy chọn',
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                color: AppColors.textMuted,
                onPressed: onMoreTap,
              )
            else
              const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _ExplicitBadge extends StatelessWidget {
  const _ExplicitBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        'E',
        style: AppTextStyles.labelSm.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
