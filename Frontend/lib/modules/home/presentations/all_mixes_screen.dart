import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/sub_page_header.dart';
import '../../../core/catalog/catalog_models.dart';
import '../../../core/catalog/music_catalog.dart';
import '../../../core/routes/app_navigator.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/playing_song_model.dart';

/// "Xem thêm" for the Mixes section on Home.
class AllMixesScreen extends StatelessWidget {
  const AllMixesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const playlists = MusicCatalog.playlists;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const SubPageHeader(title: 'Mixes cho bạn'),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Sonara AI làm mới các mix mỗi ngày dựa trên lịch sử nghe và giai điệu bạn ngân nga.',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.74,
                    ),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) =>
                        _MixGridCard(playlist: playlists[index]),
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

class _MixGridCard extends StatelessWidget {
  final CatalogPlaylist playlist;

  const _MixGridCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNavigator.openPlaylist(context, playlist.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: AppNetworkImage(
                    imageUrl: playlist.coverUrl,
                    borderRadius: 18,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: GestureDetector(
                    onTap: () => context.read<PlayerCubit>().playSong(
                          PlayingSongModel(
                            id: playlist.id,
                            title: playlist.title,
                            artist: 'Sonara AI tuyển chọn',
                            coverUrl: playlist.coverUrl,
                            durationSeconds: 220,
                            currentSeconds: 0,
                            contextHint: 'Mix • ${playlist.title}',
                          ),
                        ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: AppColors.aiGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            playlist.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            playlist.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySm,
          ),
        ],
      ),
    );
  }
}
