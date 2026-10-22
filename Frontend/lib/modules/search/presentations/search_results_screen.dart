import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/catalog_song_tile.dart';
import '../../../common/widgets/media_row_tile.dart';
import '../../../common/widgets/section_title.dart';
import '../../../core/catalog/catalog_models.dart';
import '../../../core/catalog/music_catalog.dart';
import '../../../core/routes/app_navigator.dart';
import '../../player/models/catalog_song_playback.dart';
import '../../player/presentations/sheets/song_options_sheet.dart';
import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';

/// SCR-06: Search results grouped by type.
class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(initialQuery: query),
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                final results = state.results;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Quay lại',
                            icon: const Icon(Icons.arrow_back_rounded),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).maybePop(),
                              child: Container(
                                height: 44,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceCrisp,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppColors.borderMuted,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.search_rounded,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.query,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodyLg.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textMuted,
                      indicatorColor: AppColors.primary,
                      dividerColor: AppColors.borderSubtle,
                      labelStyle: AppTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      tabs: [
                        const Tab(text: 'Tất cả'),
                        Tab(text: 'Bài hát (${results.songs.length})'),
                        Tab(text: 'Nghệ sĩ (${results.artists.length})'),
                        Tab(text: 'Album (${results.albums.length})'),
                        Tab(text: 'Playlist (${results.playlists.length})'),
                      ],
                    ),
                    Expanded(
                      child: results.isEmpty
                          ? _EmptyResults(query: state.query)
                          : TabBarView(
                              children: [
                                _AllTab(results: results, query: state.query),
                                _SongsTab(
                                  songs: results.songs,
                                  query: state.query,
                                ),
                                _ArtistsTab(artists: results.artists),
                                _AlbumsTab(albums: results.albums),
                                _PlaylistsTab(playlists: results.playlists),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

void _playSong(BuildContext context, CatalogSong song, String query) {
  AppNavigator.playAndOpen(
    context,
    song.toPlayingSong(contextHint: 'Tìm kiếm • "$query"'),
  );
}

class _AllTab extends StatelessWidget {
  final CatalogSearchResult results;
  final String query;

  const _AllTab({required this.results, required this.query});

  @override
  Widget build(BuildContext context) {
    final topArtist = results.artists.isNotEmpty ? results.artists.first : null;
    final topSong = results.songs.isNotEmpty ? results.songs.first : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          'Kết quả hàng đầu',
          style: AppTextStyles.headlineSm.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (topArtist != null)
          _TopResultCard(
            imageUrl: topArtist.avatarUrl,
            title: topArtist.name,
            subtitle: 'Nghệ sĩ • ${topArtist.monthlyListenersText}',
            isCircle: true,
            onTap: () => AppNavigator.openArtist(context, topArtist.id),
          )
        else if (topSong != null)
          _TopResultCard(
            imageUrl: topSong.coverUrl,
            title: topSong.title,
            subtitle: 'Bài hát • ${topSong.artistName}',
            onTap: () => _playSong(context, topSong, query),
            onPlay: () => _playSong(context, topSong, query),
          ),
        if (results.songs.isNotEmpty) ...[
          const SizedBox(height: 24),
          const SectionTitle(title: 'Bài hát'),
          const SizedBox(height: 6),
          for (final song in results.songs.take(4))
            CatalogSongTile(
              song: song,
              onTap: () => _playSong(context, song, query),
              onMoreTap: () =>
                  SongOptionsSheet.show(context, song.toPlayingSong()),
            ),
        ],
        if (results.artists.isNotEmpty) ...[
          const SizedBox(height: 20),
          const SectionTitle(title: 'Nghệ sĩ'),
          const SizedBox(height: 6),
          for (final artist in results.artists.take(3))
            MediaRowTile(
              imageUrl: artist.avatarUrl,
              title: artist.name,
              subtitle: artist.followersText,
              isCircle: true,
              isVerified: artist.isVerified,
              onTap: () => AppNavigator.openArtist(context, artist.id),
            ),
        ],
        if (results.albums.isNotEmpty) ...[
          const SizedBox(height: 20),
          const SectionTitle(title: 'Album'),
          const SizedBox(height: 6),
          for (final album in results.albums.take(3))
            MediaRowTile(
              imageUrl: album.coverUrl,
              title: album.title,
              subtitle: '${album.type} • ${album.year} • ${album.artistName}',
              onTap: () => AppNavigator.openAlbum(context, album.id),
            ),
        ],
        if (results.playlists.isNotEmpty) ...[
          const SizedBox(height: 20),
          const SectionTitle(title: 'Playlist'),
          const SizedBox(height: 6),
          for (final playlist in results.playlists.take(3))
            MediaRowTile(
              imageUrl: playlist.coverUrl,
              title: playlist.title,
              subtitle: playlist.subtitle,
              onTap: () => AppNavigator.openPlaylist(context, playlist.id),
            ),
        ],
      ],
    );
  }
}

class _TopResultCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final bool isCircle;
  final VoidCallback onTap;
  final VoidCallback? onPlay;

  const _TopResultCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isCircle = false,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCrisp,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A1A1A1A),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AppNetworkImage(
              imageUrl: imageUrl,
              width: 92,
              height: 92,
              borderRadius: isCircle ? 999 : 16,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineMd.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                gradient: AppColors.aiGradient,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: 'Phát',
                icon: Icon(
                  onPlay != null
                      ? Icons.play_arrow_rounded
                      : Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
                onPressed: onPlay ?? onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongsTab extends StatelessWidget {
  final List<CatalogSong> songs;
  final String query;

  const _SongsTab({required this.songs, required this.query});

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) return _EmptyResults(query: query);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: songs.length,
      itemBuilder: (context, index) => CatalogSongTile(
        song: songs[index],
        trailingText: songs[index].durationText,
        onTap: () => _playSong(context, songs[index], query),
        onMoreTap: () =>
            SongOptionsSheet.show(context, songs[index].toPlayingSong()),
      ),
    );
  }
}

class _ArtistsTab extends StatelessWidget {
  final List<CatalogArtist> artists;

  const _ArtistsTab({required this.artists});

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) return const _EmptyResults();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return MediaRowTile(
          imageUrl: artist.avatarUrl,
          title: artist.name,
          subtitle: artist.monthlyListenersText,
          isCircle: true,
          isVerified: artist.isVerified,
          onTap: () => AppNavigator.openArtist(context, artist.id),
        );
      },
    );
  }
}

class _AlbumsTab extends StatelessWidget {
  final List<CatalogAlbum> albums;

  const _AlbumsTab({required this.albums});

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) return const _EmptyResults();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return MediaRowTile(
          imageUrl: album.coverUrl,
          title: album.title,
          subtitle: '${album.type} • ${album.year} • ${album.artistName}',
          onTap: () => AppNavigator.openAlbum(context, album.id),
        );
      },
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  final List<CatalogPlaylist> playlists;

  const _PlaylistsTab({required this.playlists});

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) return const _EmptyResults();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return MediaRowTile(
          imageUrl: playlist.coverUrl,
          title: playlist.title,
          subtitle: playlist.subtitle,
          onTap: () => AppNavigator.openPlaylist(context, playlist.id),
        );
      },
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final String? query;

  const _EmptyResults({this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              query == null
                  ? 'Không có kết quả trong mục này'
                  : 'Không tìm thấy "$query"',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSm,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => AppNavigator.openHumSearch(context),
              icon: const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.primary,
              ),
              label: Text(
                'Thử tìm bằng giai điệu',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
