import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/media_row_tile.dart';
import '../../../common/widgets/sub_page_header.dart';
import '../../../core/catalog/music_catalog.dart';
import '../../../core/routes/app_navigator.dart';
import '../../../core/routes/app_router.dart';
import '../bloc/library_cubit.dart';
import '../bloc/library_state.dart';

/// All followed artists, reached from "Xem tất cả" in the Library tab.
class FollowingArtistsScreen extends StatelessWidget {
  const FollowingArtistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: Column(
            children: [
              SubPageHeader(
                title: 'Nghệ sĩ đang theo dõi',
                actions: [
                  IconButton(
                    tooltip: 'Thêm nghệ sĩ',
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    onPressed: () => AppNavigator.push(
                      context,
                      AppRouter.tastePicker,
                      arguments: false,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: state.artists.isEmpty
                    ? Center(
                        child: Text(
                          'Bạn chưa theo dõi nghệ sĩ nào',
                          style: AppTextStyles.bodyMd,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                        itemCount: state.artists.length,
                        itemBuilder: (context, index) {
                          final artist = state.artists[index];
                          final catalog = MusicCatalog.artists
                              .where((a) => a.id == artist.id)
                              .firstOrNull;
                          return MediaRowTile(
                            imageUrl: artist.avatarUrl,
                            title: artist.name,
                            subtitle: catalog?.monthlyListenersText ??
                                (artist.hasNewUpdate
                                    ? 'Có bài hát mới'
                                    : 'Nghệ sĩ'),
                            isCircle: true,
                            isVerified: artist.isVerified,
                            onTap: () =>
                                AppNavigator.openArtist(context, artist.id),
                            trailing: OutlinedButton(
                              onPressed: () => context
                                  .read<LibraryCubit>()
                                  .toggleFollowArtist(artist),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textCharcoal,
                                side: const BorderSide(
                                  color: AppColors.borderMuted,
                                ),
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text('Bỏ theo dõi'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
