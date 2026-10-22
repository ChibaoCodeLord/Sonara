import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/catalog_song_tile.dart';
import '../../../common/widgets/media_card.dart';
import '../../../common/widgets/section_title.dart';
import '../../../core/catalog/catalog_models.dart';
import '../../../core/routes/app_navigator.dart';
import '../../library/bloc/library_cubit.dart';
import '../../library/bloc/library_state.dart';
import '../../library/models/following_artist_model.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/catalog_song_playback.dart';
import '../../player/presentations/sheets/share_song_sheet.dart';
import '../../player/presentations/sheets/song_options_sheet.dart';
import '../bloc/artist_cubit.dart';
import '../bloc/artist_state.dart';

/// SCR-07: Artist profile with parallax cover, top songs and discography.
class ArtistDetailScreen extends StatelessWidget {
  final String artistId;

  const ArtistDetailScreen({super.key, required this.artistId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArtistCubit(artistId: artistId),
      child: BlocBuilder<ArtistCubit, ArtistState>(
        builder: (context, state) {
          final artist = state.artist;
          final cubit = context.read<ArtistCubit>();
          final hint = 'Nghệ sĩ • ${artist.name}';

          void playSongs(List<CatalogSong> songs) {
            context.read<PlayerCubit>().playAll(
              songs.map((s) => s.toPlayingSong(contextHint: hint)).toList(),
            );
            AppNavigator.openNowPlaying(context);
          }

          return Scaffold(
            backgroundColor: AppColors.surface,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, artist),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  sliver: SliverList.list(
                    children: [
                      _ActionRow(
                        artist: artist,
                        onShuffle: () =>
                            playSongs([...state.topSongs]..shuffle()),
                        onPlay: () => playSongs(state.topSongs),
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Phổ biến'),
                      const SizedBox(height: 6),
                      for (var i = 0; i < state.visibleTopSongs.length; i++)
                        CatalogSongTile(
                          song: state.visibleTopSongs[i],
                          index: i + 1,
                          trailingText: state.visibleTopSongs[i].playsText,
                          onTap: () => AppNavigator.playAndOpen(
                            context,
                            state.visibleTopSongs[i].toPlayingSong(
                              contextHint: hint,
                            ),
                          ),
                          onMoreTap: () => SongOptionsSheet.show(
                            context,
                            state.visibleTopSongs[i].toPlayingSong(
                              contextHint: hint,
                            ),
                          ),
                        ),
                      if (state.topSongs.length > 5)
                        Center(
                          child: TextButton(
                            onPressed: cubit.toggleShowAllTopSongs,
                            child: Text(
                              state.showAllTopSongs ? 'Thu gọn' : 'Xem thêm',
                              style: AppTextStyles.labelLg.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const SectionTitle(title: 'Danh sách đĩa nhạc'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final (key, label) in const [
                            ('all', 'Tất cả'),
                            ('album', 'Album'),
                            ('single', 'Single & EP'),
                          ])
                            ChoiceChip(
                              label: Text(label),
                              selected: state.discographyFilter == key,
                              showCheckmark: false,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surfaceCrisp,
                              side: const BorderSide(
                                color: AppColors.borderMuted,
                              ),
                              labelStyle: AppTextStyles.labelMd.copyWith(
                                color: state.discographyFilter == key
                                    ? Colors.white
                                    : AppColors.textCharcoal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              onSelected: (_) =>
                                  cubit.setDiscographyFilter(key),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _HorizontalCards(
                        emptyText: 'Chưa có phát hành trong mục này',
                        children: [
                          for (final album in state.filteredDiscography)
                            MediaCard(
                              imageUrl: album.coverUrl,
                              title: album.title,
                              subtitle: '${album.year} • ${album.type}',
                              onTap: () =>
                                  AppNavigator.openAlbum(context, album.id),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _AboutCard(artist: artist),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Xuất hiện trong'),
                      const SizedBox(height: 12),
                      _HorizontalCards(
                        children: [
                          for (final playlist in state.appearsOn)
                            MediaCard(
                              imageUrl: playlist.coverUrl,
                              title: playlist.title,
                              subtitle: playlist.subtitle,
                              onTap: () => AppNavigator.openPlaylist(
                                context,
                                playlist.id,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Nghệ sĩ tương tự'),
                      const SizedBox(height: 12),
                      _HorizontalCards(
                        height: 170,
                        children: [
                          for (final similar in state.similarArtists)
                            MediaCard(
                              imageUrl: similar.avatarUrl,
                              title: similar.name,
                              subtitle: 'Nghệ sĩ',
                              isCircle: true,
                              size: 116,
                              onTap: () =>
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => ArtistDetailScreen(
                                        artistId: similar.id,
                                      ),
                                    ),
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, CatalogArtist artist) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 320,
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          tooltip: 'Chia sẻ',
          icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
          onPressed: () => ShareSongSheet.show(
            context,
            id: artist.id,
            title: artist.name,
            subtitle: artist.monthlyListenersText,
            coverUrl: artist.avatarUrl,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 14),
        title: Text(
          artist.name,
          style: AppTextStyles.headlineSm.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(imageUrl: artist.coverUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x00000000),
                    Color(0xCC1A0006),
                  ],
                  stops: [0, 0.4, 1],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 52,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (artist.isVerified)
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF60A5FA),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Nghệ sĩ đã xác minh',
                          style: AppTextStyles.labelMd.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    artist.monthlyListenersText,
                    style: AppTextStyles.bodySm.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final CatalogArtist artist;
  final VoidCallback onShuffle;
  final VoidCallback onPlay;

  const _ActionRow({
    required this.artist,
    required this.onShuffle,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, libraryState) {
        final isFollowing = libraryState.artists.any((a) => a.id == artist.id);
        return Row(
          children: [
            Flexible(
              child: OutlinedButton(
                onPressed: () =>
                    context.read<LibraryCubit>().toggleFollowArtist(
                      FollowingArtistModel(
                        id: artist.id,
                        name: artist.name,
                        avatarUrl: artist.avatarUrl,
                        isVerified: artist.isVerified,
                      ),
                    ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? AppColors.primaryFixed
                      : Colors.transparent,
                  side: BorderSide(
                    color: isFollowing
                        ? AppColors.primary
                        : AppColors.borderMuted,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLg.copyWith(
                    color: isFollowing
                        ? AppColors.primary
                        : AppColors.textCharcoal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                artist.followersText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySm,
              ),
            ),
            IconButton(
              tooltip: 'Phát ngẫu nhiên',
              icon: const Icon(
                Icons.shuffle_rounded,
                color: AppColors.textCharcoal,
              ),
              onPressed: onShuffle,
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onPlay,
              child: Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  gradient: AppColors.aiGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40B3122E),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AboutCard extends StatelessWidget {
  final CatalogArtist artist;

  const _AboutCard({required this.artist});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceCrisp,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppNetworkImage(
            imageUrl: artist.avatarUrl,
            width: double.infinity,
            height: 160,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giới thiệu',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  artist.bio,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final genre in artist.genres)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(genre, style: AppTextStyles.labelSm),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalCards extends StatelessWidget {
  final List<Widget> children;
  final double height;
  final String? emptyText;

  const _HorizontalCards({
    required this.children,
    this.height = 190,
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(emptyText ?? '', style: AppTextStyles.bodySm),
      );
    }
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, index) => children[index],
      ),
    );
  }
}
