import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/catalog_song_tile.dart';
import '../../../common/widgets/media_row_tile.dart';
import '../../../common/widgets/section_title.dart';
import '../../../core/catalog/music_catalog.dart';
import '../../../core/routes/app_navigator.dart';
import '../../../core/routes/app_router.dart';
import '../../player/models/catalog_song_playback.dart';
import '../../player/presentations/sheets/song_options_sheet.dart';
import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';
import 'widgets/browse_category_card.dart';
import 'widgets/search_input_bar.dart';

/// SCR-05: Text search with recent searches and browse categories.
class SearchScreen extends StatelessWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(),
      child: _SearchView(initialQuery: initialQuery),
    );
  }
}

class _SearchView extends StatefulWidget {
  final String? initialQuery;

  const _SearchView({this.initialQuery});

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    if (_controller.text.isNotEmpty) {
      context.read<SearchCubit>().onQueryChanged(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openResults(String query) {
    if (query.trim().isEmpty) return;
    context.read<SearchCubit>().submit(query);
    _focusNode.unfocus();
    AppNavigator.push(context, AppRouter.searchResults, arguments: query.trim());
  }

  void _useQuery(String query) {
    _controller.text = query;
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    _openResults(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Quay lại',
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: SearchInputBar(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: widget.initialQuery == null,
                      onChanged: context.read<SearchCubit>().onQueryChanged,
                      onSubmitted: _openResults,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _RoundIconButton(
                    icon: Icons.qr_code_scanner_rounded,
                    tooltip: 'Quét Wave Code',
                    onTap: () =>
                        AppNavigator.push(context, AppRouter.waveCodeScanner),
                  ),
                  const SizedBox(width: 6),
                  _RoundIconButton(
                    icon: Icons.graphic_eq_rounded,
                    tooltip: 'Tìm bằng giai điệu',
                    filled: true,
                    onTap: () => AppNavigator.openHumSearch(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state.query.isEmpty) return _buildIdle(context, state);
                  return _buildLiveResults(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdle(BuildContext context, SearchState state) {
    final cubit = context.read<SearchCubit>();
    return ListView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (state.recentSearches.isNotEmpty) ...[
          SectionTitle(
            title: 'Tìm kiếm gần đây',
            actionLabel: 'Xóa tất cả',
            onActionTap: cubit.clearRecent,
          ),
          const SizedBox(height: 4),
          for (final query in state.recentSearches)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.history_rounded,
                color: AppColors.textMuted,
              ),
              title: Text(query, style: AppTextStyles.bodyLg),
              trailing: IconButton(
                tooltip: 'Xóa',
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: () => cubit.removeRecent(query),
              ),
              onTap: () => _useQuery(query),
            ),
          const SizedBox(height: 16),
        ],
        Text(
          'Xu hướng tìm kiếm',
          style: AppTextStyles.headlineSm.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final keyword in state.trendingKeywords)
              ActionChip(
                avatar: const Icon(
                  Icons.trending_up_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(keyword),
                labelStyle: AppTextStyles.labelMd,
                backgroundColor: AppColors.surfaceCrisp,
                side: const BorderSide(color: AppColors.borderMuted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                onPressed: () => _useQuery(keyword),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Khám phá chủ đề',
          style: AppTextStyles.headlineSm.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: MusicCatalog.browseCategories.length,
          itemBuilder: (context, index) {
            final category = MusicCatalog.browseCategories[index];
            return BrowseCategoryCard(
              category: category,
              onTap: () => AppNavigator.push(
                context,
                AppRouter.categoryDetail,
                arguments: category,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLiveResults(BuildContext context, SearchState state) {
    final results = state.results;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        if (state.isSearching)
          const LinearProgressIndicator(
            minHeight: 2,
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceContainer,
          ),
        if (!state.isSearching && results.isEmpty)
          _NoResults(
            query: state.query,
            onHumTap: () => AppNavigator.openHumSearch(context),
          ),
        for (final artist in results.artists.take(2))
          MediaRowTile(
            imageUrl: artist.avatarUrl,
            title: artist.name,
            subtitle: 'Nghệ sĩ',
            isCircle: true,
            isVerified: artist.isVerified,
            onTap: () => AppNavigator.openArtist(context, artist.id),
          ),
        for (final song in results.songs.take(5))
          CatalogSongTile(
            song: song,
            onTap: () => AppNavigator.playAndOpen(
              context,
              song.toPlayingSong(contextHint: 'Tìm kiếm • "${state.query}"'),
            ),
            onMoreTap: () =>
                SongOptionsSheet.show(context, song.toPlayingSong()),
          ),
        for (final album in results.albums.take(2))
          MediaRowTile(
            imageUrl: album.coverUrl,
            title: album.title,
            subtitle: '${album.type} • ${album.artistName}',
            onTap: () => AppNavigator.openAlbum(context, album.id),
          ),
        if (!results.isEmpty) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _openResults(state.query),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.borderMuted),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'Xem tất cả kết quả cho "${state.query}"',
              style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool filled;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: filled ? AppColors.aiGradient : null,
            color: filled ? null : AppColors.surfaceContainer,
          ),
          child: Icon(
            icon,
            color: filled ? Colors.white : AppColors.textCharcoal,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  final VoidCallback onHumTap;

  const _NoResults({required this.query, required this.onHumTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'Không tìm thấy "$query"',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSm,
          ),
          const SizedBox(height: 6),
          Text(
            'Thử từ khóa khác, hoặc ngân nga giai điệu để Sonara AI nhận diện.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: onHumTap,
            icon: const Icon(Icons.graphic_eq_rounded),
            label: const Text('Tìm bằng giai điệu'),
          ),
        ],
      ),
    );
  }
}
