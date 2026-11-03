import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/gradient_button.dart';
import '../../../core/catalog/catalog_models.dart';
import '../../../core/catalog/music_catalog.dart';
import '../../../core/routes/app_router.dart';
import '../../library/bloc/library_cubit.dart';
import '../../library/bloc/library_state.dart';
import '../../library/models/following_artist_model.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import 'widgets/auth_step_indicator.dart';

/// SCR-04: Pick genres and artists to seed recommendations.
///
/// With [isOnboarding] false it doubles as the "follow more artists" page
/// opened from the Library tab.
class TastePickerScreen extends StatelessWidget {
  final bool isOnboarding;

  const TastePickerScreen({super.key, this.isOnboarding = true});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, libraryState) {
            final authCubit = context.read<AuthCubit>();
            final libraryCubit = context.read<LibraryCubit>();
            final followedIds = libraryState.artists.map((a) => a.id).toSet();
            final selectedArtists = isOnboarding
                ? authState.selectedArtistIds
                : followedIds;
            final count = isOnboarding
                ? authState.tasteSelectionCount
                : followedIds.length;
            final canContinue =
                !isOnboarding || count >= AuthCubit.minTasteSelections;

            return Scaffold(
              backgroundColor: AppColors.surface,
              appBar: isOnboarding ? null : AppBar(),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                            sliver: SliverList.list(
                              children: [
                                if (isOnboarding) ...[
                                  const AuthStepIndicator(step: 3),
                                  const SizedBox(height: 24),
                                ],
                                Text(
                                  isOnboarding
                                      ? 'Gu âm nhạc của bạn là gì?'
                                      : 'Theo dõi thêm nghệ sĩ',
                                  style: AppTextStyles.headlineLg.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isOnboarding
                                      ? 'Chọn tối thiểu 3 mục để Sonara AI cá nhân hóa trang chủ cho bạn.'
                                      : 'Nhận thông báo khi nghệ sĩ bạn yêu thích ra nhạc mới.',
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (isOnboarding) ...[
                                  Text(
                                    'Thể loại',
                                    style: AppTextStyles.headlineSm.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 10,
                                    children: [
                                      for (final genre
                                          in MusicCatalog.tasteGenres)
                                        _GenreChip(
                                          label: genre,
                                          selected: authState.selectedGenres
                                              .contains(genre),
                                          onTap: () =>
                                              authCubit.toggleGenre(genre),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                ],
                                Text(
                                  'Nghệ sĩ',
                                  style: AppTextStyles.headlineSm.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            sliver: SliverGrid.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 110,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.78,
                              ),
                              itemCount: MusicCatalog.artists.length,
                              itemBuilder: (context, index) {
                                final artist = MusicCatalog.artists[index];
                                return _ArtistBubble(
                                  artist: artist,
                                  selected:
                                      selectedArtists.contains(artist.id),
                                  onTap: () {
                                    if (isOnboarding) {
                                      authCubit.toggleArtist(artist.id);
                                    } else {
                                      libraryCubit.toggleFollowArtist(
                                        FollowingArtistModel(
                                          id: artist.id,
                                          name: artist.name,
                                          avatarUrl: artist.avatarUrl,
                                          isVerified: artist.isVerified,
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          top: BorderSide(color: AppColors.borderSubtle),
                        ),
                      ),
                      child: GradientButton(
                        label: isOnboarding
                            ? (canContinue
                                ? 'Hoàn tất & Khám phá'
                                : 'Chọn thêm ${AuthCubit.minTasteSelections - count} mục')
                            : 'Xong ($count nghệ sĩ)',
                        onPressed: canContinue
                            ? () {
                                if (isOnboarding) {
                                  _followSelectedArtists(
                                    libraryCubit,
                                    authState.selectedArtistIds,
                                  );
                                  Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                    AppRouter.shell,
                                    (_) => false,
                                  );
                                } else {
                                  Navigator.of(context).pop();
                                }
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _followSelectedArtists(LibraryCubit cubit, Set<String> artistIds) {
    for (final id in artistIds) {
      if (cubit.isFollowing(id)) continue;
      final artist = MusicCatalog.artistById(id);
      cubit.toggleFollowArtist(
        FollowingArtistModel(
          id: artist.id,
          name: artist.name,
          avatarUrl: artist.avatarUrl,
          isVerified: artist.isVerified,
        ),
      );
    }
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenreChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.aiGradient : null,
          color: selected ? null : AppColors.surfaceCrisp,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.borderMuted,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.labelLg.copyWith(
                color: selected ? Colors.white : AppColors.textCharcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistBubble extends StatelessWidget {
  final CatalogArtist artist;
  final bool selected;
  final VoidCallback onTap;

  const _ArtistBubble({
    required this.artist,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selected ? AppColors.aiGradient : null,
                ),
                child: AppNetworkImage(
                  imageUrl: artist.avatarUrl,
                  width: 76,
                  height: 76,
                  borderRadius: 999,
                ),
              ),
              if (selected)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            artist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMd.copyWith(
              color: selected ? AppColors.primary : AppColors.textCharcoal,
            ),
          ),
        ],
      ),
    );
  }
}
