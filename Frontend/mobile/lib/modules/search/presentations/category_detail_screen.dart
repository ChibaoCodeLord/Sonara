import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/catalog_song_tile.dart';
import '../../../common/widgets/media_card.dart';
import '../../../common/widgets/section_title.dart';
import '../../../core/catalog/catalog_models.dart';
import '../../../core/catalog/music_catalog.dart';
import '../../../core/routes/app_navigator.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/catalog_song_playback.dart';
import '../../player/presentations/sheets/song_options_sheet.dart';

/// Browse category / mood / genre page reached from Search and Charts.
class CategoryDetailScreen extends StatelessWidget {
  final CatalogCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final songs = MusicCatalog.songsForTag(category.id, count: 10);
    final playlists = [...MusicCatalog.playlists]
      ..sort((a, b) => (a.id.hashCode ^ category.id.hashCode)
          .compareTo(b.id.hashCode ^ category.id.hashCode));
    final hint = 'Chủ đề • ${category.title}';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: category.colors.first,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              category.title,
              style: AppTextStyles.headlineSm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: category.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        category.icon,
                        size: 180,
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title,
                            style: AppTextStyles.displayLgMobile.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${category.subtitle} • ${songs.length} bài hát',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          context.read<PlayerCubit>().playAll(
                                songs
                                    .map((s) => s.toPlayingSong(contextHint: hint))
                                    .toList(),
                              );
                          AppNavigator.openNowPlaying(context);
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Phát tất cả'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.borderMuted),
                        ),
                        onPressed: () {
                          final shuffled = [...songs]..shuffle();
                          context.read<PlayerCubit>().playAll(
                                shuffled
                                    .map((s) => s.toPlayingSong(contextHint: hint))
                                    .toList(),
                              );
                          AppNavigator.openNowPlaying(context);
                        },
                        icon: const Icon(Icons.shuffle_rounded),
                        label: const Text('Phát ngẫu nhiên'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SectionTitle(title: 'Bài hát nổi bật'),
                const SizedBox(height: 6),
                for (var i = 0; i < songs.length; i++)
                  CatalogSongTile(
                    song: songs[i],
                    index: i + 1,
                    onTap: () => AppNavigator.playAndOpen(
                      context,
                      songs[i].toPlayingSong(contextHint: hint),
                    ),
                    onMoreTap: () => SongOptionsSheet.show(
                      context,
                      songs[i].toPlayingSong(contextHint: hint),
                    ),
                  ),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Playlist cùng chủ đề'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return MediaCard(
                        imageUrl: playlist.coverUrl,
                        title: playlist.title,
                        subtitle: playlist.subtitle,
                        onTap: () =>
                            AppNavigator.openPlaylist(context, playlist.id),
                      );
                    },
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
