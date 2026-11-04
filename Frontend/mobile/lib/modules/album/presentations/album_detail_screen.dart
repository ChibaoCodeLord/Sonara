import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/catalog_song_tile.dart';
import '../../../common/widgets/media_card.dart';
import '../../../common/widgets/section_title.dart';
import '../../../common/widgets/sub_page_header.dart';
import '../../../core/routes/app_navigator.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/catalog_song_playback.dart';
import '../../player/presentations/sheets/share_song_sheet.dart';
import '../../player/presentations/sheets/song_options_sheet.dart';
import '../bloc/album_cubit.dart';
import '../bloc/album_state.dart';

/// SCR-08: Album / single / EP detail.
class AlbumDetailScreen extends StatelessWidget {
  final String albumId;

  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AlbumCubit(albumId: albumId),
      child: BlocBuilder<AlbumCubit, AlbumState>(
        builder: (context, state) {
          final album = state.album;
          final cubit = context.read<AlbumCubit>();
          final hint = '${album.type} • ${album.title}';
          final totalMinutes = (state.totalSeconds / 60).round();

          return Scaffold(
            backgroundColor: AppColors.surface,
            body: Column(
              children: [
                SubPageHeader(
                  title: album.type,
                  actions: [
                    IconButton(
                      tooltip: 'Chia sẻ',
                      icon: const Icon(Icons.ios_share_rounded),
                      onPressed: () => ShareSongSheet.show(
                        context,
                        id: album.id,
                        title: album.title,
                        subtitle: album.artistName,
                        coverUrl: album.coverUrl,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 24,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: AppNetworkImage(
                            imageUrl: album.coverUrl,
                            width: 240,
                            height: 240,
                            borderRadius: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        album.title,
                        style: AppTextStyles.headlineLg.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () =>
                            AppNavigator.openArtist(context, album.artistId),
                        child: Text(
                          album.artistName,
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${album.type} • ${album.year} • ${state.tracks.length} bài • $totalMinutes phút',
                            style: AppTextStyles.bodySm,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              album.quality,
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          IconButton(
                            tooltip: state.isSaved
                                ? 'Bỏ lưu khỏi thư viện'
                                : 'Lưu vào thư viện',
                            icon: Icon(
                              state.isSaved
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: state.isSaved
                                  ? AppColors.secondary
                                  : AppColors.textCharcoal,
                            ),
                            onPressed: () {
                              cubit.toggleSaved();
                              AppNavigator.showMessage(
                                context,
                                state.isSaved
                                    ? 'Đã xóa khỏi thư viện'
                                    : 'Đã lưu vào thư viện',
                              );
                            },
                          ),
                          _DownloadButton(
                            state: state,
                            onTap: cubit.toggleDownload,
                          ),
                          IconButton(
                            tooltip: 'Tùy chọn',
                            icon: const Icon(Icons.more_horiz_rounded),
                            onPressed: state.tracks.isEmpty
                                ? null
                                : () => SongOptionsSheet.show(
                                      context,
                                      state.tracks.first
                                          .toPlayingSong(contextHint: hint),
                                    ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Phát ngẫu nhiên',
                            icon: const Icon(Icons.shuffle_rounded),
                            onPressed: () {
                              final shuffled = [...state.tracks]..shuffle();
                              context.read<PlayerCubit>().playAll(
                                    shuffled
                                        .map((s) =>
                                            s.toPlayingSong(contextHint: hint))
                                        .toList(),
                                  );
                              AppNavigator.openNowPlaying(context);
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<PlayerCubit>().playAll(
                                    state.tracks
                                        .map((s) =>
                                            s.toPlayingSong(contextHint: hint))
                                        .toList(),
                                  );
                              AppNavigator.openNowPlaying(context);
                            },
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: const BoxDecoration(
                                gradient: AppColors.aiGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (state.isDownloading) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: state.downloadProgress,
                          color: AppColors.primary,
                          backgroundColor: AppColors.surfaceContainer,
                          minHeight: 3,
                        ),
                      ],
                      const SizedBox(height: 16),
                      for (var i = 0; i < state.tracks.length; i++)
                        CatalogSongTile(
                          song: state.tracks[i],
                          index: i + 1,
                          showCover: false,
                          trailingText: state.tracks[i].durationText,
                          badge: state.isDownloaded
                              ? const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(
                                    Icons.download_done_rounded,
                                    size: 16,
                                    color: AppColors.emeraldActive,
                                  ),
                                )
                              : null,
                          onTap: () => AppNavigator.playAndOpen(
                            context,
                            state.tracks[i].toPlayingSong(contextHint: hint),
                          ),
                          onMoreTap: () => SongOptionsSheet.show(
                            context,
                            state.tracks[i].toPlayingSong(contextHint: hint),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'Phát hành năm ${album.year}',
                        style: AppTextStyles.labelLg,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '℗ ${album.year} ${album.label}',
                        style: AppTextStyles.bodySm,
                      ),
                      const SizedBox(height: 28),
                      SectionTitle(title: 'Thêm từ ${album.artistName}'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 190,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.moreAlbums.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final other = state.moreAlbums[index];
                            return MediaCard(
                              imageUrl: other.coverUrl,
                              title: other.title,
                              subtitle: '${other.year} • ${other.type}',
                              onTap: () => Navigator.of(context)
                                  .pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AlbumDetailScreen(albumId: other.id),
                                ),
                              ),
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
        },
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final AlbumState state;
  final VoidCallback onTap;

  const _DownloadButton({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (state.isDownloading) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            value: state.downloadProgress,
            strokeWidth: 2.5,
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceContainer,
          ),
        ),
      );
    }
    return IconButton(
      tooltip: state.isDownloaded ? 'Xóa bản tải' : 'Tải toàn bộ album',
      icon: Icon(
        state.isDownloaded
            ? Icons.download_done_rounded
            : Icons.download_for_offline_outlined,
        color: state.isDownloaded
            ? AppColors.emeraldActive
            : AppColors.textCharcoal,
      ),
      onPressed: onTap,
    );
  }
}
