import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/pulsing_dot.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/playing_song_model.dart';
import '../../player/presentations/now_playing_screen.dart';
import '../bloc/hum_search_cubit.dart';
import '../bloc/hum_search_state.dart';
import 'hum_to_search_screen.dart';
import 'widgets/best_match_card.dart';
import 'widgets/candidate_track_card.dart';
import 'widgets/troubleshooting_card.dart';

class HumSearchResultScreen extends StatelessWidget {
  const HumSearchResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HumSearchCubit, HumSearchState>(
      builder: (context, state) {
        final result = state.result;
        final cubit = context.read<HumSearchCubit>();

        if (result == null) {
          return const Scaffold(
            backgroundColor: AppColors.surface,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Top Navigation Header
                _buildHeader(context),

                // Result Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AI Status Banner Chip
                        _buildStatusBanner(context, cubit, result.confidenceScore),
                        const SizedBox(height: 16),

                        // Best Match (Top 1) Highlighted Card
                        BestMatchCard(
                          match: result.bestMatch,
                          isSnippetPlaying: state.isSnippetPlaying,
                          onToggleSnippet: () => cubit.toggleSnippetPlay(),
                          onToggleFavorite: () => cubit.toggleFavorite(result.bestMatch.id),
                          onAddToPlaylist: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã thêm vào danh sách phát'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          onPlayFull: () {
                            context.read<PlayerCubit>().playSong(
                                  PlayingSongModel(
                                    id: result.bestMatch.id,
                                    title: result.bestMatch.title,
                                    artist: result.bestMatch.artist,
                                    coverUrl: result.bestMatch.coverUrl,
                                    album: result.bestMatch.album,
                                    durationSeconds: 235,
                                    currentSeconds: 75,
                                    isLossless: true,
                                    isExplicit: true,
                                    isFavorite: result.bestMatch.isFavorite,
                                    contextHint: 'AI Hum Match (${result.bestMatch.matchPercentage}%)',
                                  ),
                                );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const NowPlayingScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Other AI Match Candidates
                        _buildCandidatesSection(context, result),
                        const SizedBox(height: 24),

                        // Smart Troubleshooting Hint
                        TroubleshootingCard(
                          onRetryHum: () => _retryHum(context, cubit),
                          onSearchByLyrics: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mở tìm kiếm bằng từ khóa...'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textCharcoal,
                  size: 24,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppColors.aiGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Hum To Search',
                style: AppTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.share_rounded,
                  color: AppColors.textCharcoal,
                  size: 22,
                ),
                onPressed: () {},
              ),
              Container(
                width: 34,
                height: 34,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: const AppNetworkImage(
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuD7duxPs1DpjO6pOuSivTM7hDgDn1CrarsTO1-5t9k7n2pg7ZEjcFNr0ZMzHssB3UfCVaaynS09o4TvAh4O56tfzkxG4SJ3rD8eoWA1yYo-gtp2XHrwxfF32iOaFhIwlbcUO5uiYmtpyfMS9ttmmhvuj4x2Ys3hI6QZhz4CEWhLoVRag1dpg3ctZI21MA9bTvRyZaPt9vMXhbTVVeV9NJSNSESPTHqdkpo4VvrQkJ-dsh-WastTqTnNlQ',
                  borderRadius: 999,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, HumSearchCubit cubit, int confidence) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đã tìm thấy 3 bài hát tương đồng',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const PulsingDot(
                        color: AppColors.primary,
                        size: 5,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Độ tin cậy AI: $confidence%',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _retryHum(context, cubit),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceCrisp,
              foregroundColor: AppColors.textCharcoal,
              elevation: 1,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: const Icon(Icons.mic_rounded, size: 16, color: AppColors.primary),
            label: Text(
              'Hát lại',
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesSection(BuildContext context, dynamic result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kết quả tiềm năng khác',
              style: AppTextStyles.headlineSm.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${result.otherCandidates.length} kết quả',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...result.otherCandidates.map<Widget>((candidate) {
          return CandidateTrackCard(
            candidate: candidate,
            onPlayTap: () {
              context.read<PlayerCubit>().playSong(
                    PlayingSongModel(
                      id: candidate.id,
                      title: candidate.title,
                      artist: candidate.artist,
                      coverUrl: candidate.coverUrl,
                      album: candidate.album,
                      durationSeconds: 210,
                      currentSeconds: 0,
                      contextHint: 'AI Hum Match (${candidate.matchPercentage}%)',
                    ),
                  );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NowPlayingScreen(),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }

  void _retryHum(BuildContext context, HumSearchCubit cubit) {
    cubit.startListening();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const HumToSearchScreen(),
        ),
      ),
    );
  }
}
