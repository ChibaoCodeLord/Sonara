import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_bottom_sheet.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../core/routes/app_navigator.dart';
import '../../../core/utils/formatters.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';
import '../models/lyric_line_model.dart';
import '../models/playing_song_model.dart';
import '../services/player_service.dart';

/// SCR-11: Full-screen synced lyrics with Karaoke mode and quote cards.
class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  final _service = PlayerService();
  final _scrollController = ScrollController();
  late List<LyricLineModel> _lines;
  late List<GlobalKey> _lineKeys;
  Timer? _ticker;
  bool _largeText = false;
  int _lastActiveIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadLyrics(context.read<PlayerCubit>().state.song.id);
    // Playback is simulated: advance the clock while the song is playing so
    // the highlighted line follows along.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final cubit = context.read<PlayerCubit>();
      final song = cubit.state.song;
      if (!cubit.state.isPlaying) return;
      if (song.currentSeconds >= song.durationSeconds) {
        cubit.playNext();
      } else {
        cubit.seek(song.currentSeconds + 1);
      }
    });
  }

  void _loadLyrics(String songId) {
    _lines = _service.getFullLyrics(songId);
    _lineKeys = List.generate(_lines.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  int _activeIndex(int currentSeconds) {
    var active = -1;
    for (var i = 0; i < _lines.length; i++) {
      if (_lines[i].timeSeconds <= currentSeconds) active = i;
    }
    return active;
  }

  void _scrollToActive(int index) {
    if (index == _lastActiveIndex || index < 0) return;
    _lastActiveIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lineContext = _lineKeys[index].currentContext;
      if (lineContext == null) return;
      Scrollable.ensureVisible(
        lineContext,
        alignment: 0.35,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerCubit, PlayerState>(
      listenWhen: (prev, curr) => prev.song.id != curr.song.id,
      listener: (context, state) {
        setState(() {
          _loadLyrics(state.song.id);
          _lastActiveIndex = -1;
        });
      },
      builder: (context, state) {
        final cubit = context.read<PlayerCubit>();
        final song = state.song;
        final active = _activeIndex(song.currentSeconds);
        _scrollToActive(active);

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5C0A18), Color(0xFF9A1B2F), Color(0xFF2A0710)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context, song),
                  _buildModeBar(state, cubit),
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (rect) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ],
                        stops: [0, 0.08, 0.88, 1],
                      ).createShader(rect),
                      blendMode: BlendMode.dstIn,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 160),
                        itemCount: _lines.length,
                        itemBuilder: (context, index) {
                          final line = _lines[index];
                          final isActive = index == active;
                          final isPast = index < active;
                          return GestureDetector(
                            key: _lineKeys[index],
                            onTap: () => cubit.seek(line.timeSeconds),
                            onLongPress: () =>
                                _LyricQuoteSheet.show(context, song, line.text),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: (_largeText
                                        ? AppTextStyles.headlineLg
                                        : AppTextStyles.headlineMd)
                                    .copyWith(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white.withValues(
                                          alpha: isPast ? 0.45 : 0.3,
                                        ),
                                  fontWeight: isActive
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  height: 1.3,
                                ),
                                child: Text(line.text),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  _buildBottomControls(state, cubit),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, PlayingSongModel song) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Đóng',
            icon: const Icon(
              Icons.expand_more_rounded,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppNetworkImage(
            imageUrl: song.coverUrl,
            width: 40,
            height: 40,
            borderRadius: 8,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cỡ chữ',
            icon: Icon(
              _largeText ? Icons.text_decrease_rounded : Icons.text_increase_rounded,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _largeText = !_largeText),
          ),
          IconButton(
            tooltip: 'Tạo thẻ trích dẫn',
            icon: const Icon(Icons.format_quote_rounded, color: Colors.white),
            onPressed: () {
              final active = _activeIndex(song.currentSeconds);
              _LyricQuoteSheet.show(
                context,
                song,
                _lines[active < 0 ? 0 : active].text,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeBar(PlayerState state, PlayerCubit cubit) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: GestureDetector(
        onTap: cubit.toggleKaraokeMode,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: state.isKaraokeMode
                ? Colors.white
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Icon(
                Icons.mic_external_on_rounded,
                size: 18,
                color: state.isKaraokeMode ? AppColors.primary : Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.isKaraokeMode
                      ? 'Chế độ Karaoke • Đã giảm 90% vocal ca sĩ'
                      : 'Bật Karaoke (AI Stem Separation)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMd.copyWith(
                    color: state.isKaraokeMode
                        ? AppColors.primary
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                state.isKaraokeMode
                    ? Icons.toggle_on_rounded
                    : Icons.toggle_off_rounded,
                size: 30,
                color: state.isKaraokeMode ? AppColors.primary : Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(PlayerState state, PlayerCubit cubit) {
    final song = state.song;
    final progress = song.durationSeconds == 0
        ? 0.0
        : song.currentSeconds / song.durationSeconds;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (v) => cubit.seek((v * song.durationSeconds).round()),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                Formatters.formatSeconds(song.currentSeconds),
                style: AppTextStyles.labelSm.copyWith(color: Colors.white70),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                iconSize: 32,
                onPressed: cubit.playPrevious,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: cubit.togglePlayPause,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    state.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.primary,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                iconSize: 32,
                onPressed: cubit.playNext,
              ),
              const Spacer(),
              Text(
                Formatters.formatSeconds(
                  song.durationSeconds - song.currentSeconds,
                  negative: true,
                ),
                style: AppTextStyles.labelSm.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Lyric Quote Card: a shareable story-style card for a favourite line.
class _LyricQuoteSheet extends StatefulWidget {
  final PlayingSongModel song;
  final String line;

  const _LyricQuoteSheet({required this.song, required this.line});

  static Future<void> show(
    BuildContext context,
    PlayingSongModel song,
    String line,
  ) {
    return showAppBottomSheet<void>(
      context: context,
      title: 'Thẻ trích dẫn lời bài hát',
      subtitle: 'Chia sẻ câu hát yêu thích lên Story',
      builder: (_) => _LyricQuoteSheet(song: song, line: line),
    );
  }

  @override
  State<_LyricQuoteSheet> createState() => _LyricQuoteSheetState();
}

class _LyricQuoteSheetState extends State<_LyricQuoteSheet> {
  static const _palettes = [
    [Color(0xFFB3122E), Color(0xFFFF4B4B)],
    [Color(0xFF1A1A1A), Color(0xFF62656B)],
    [Color(0xFF3F6B5B), Color(0xFF7FB69E)],
    [Color(0xFF2B4162), Color(0xFF6B8CAE)],
  ];
  int _palette = 0;

  @override
  Widget build(BuildContext context) {
    final colors = _palettes[_palette];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    color: Colors.white54,
                    size: 40,
                  ),
                  const Spacer(),
                  Text(
                    widget.line,
                    style: AppTextStyles.headlineMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      AppNetworkImage(
                        imageUrl: widget.song.coverUrl,
                        width: 40,
                        height: 40,
                        borderRadius: 8,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelLg.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              widget.song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySm.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.graphic_eq_rounded, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Sonara',
                        style: AppTextStyles.labelMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _palettes.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _palette = i),
                  child: Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: _palettes[i]),
                      border: Border.all(
                        color: i == _palette
                            ? AppColors.textCharcoal
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                AppNavigator.showMessage(context, 'Đã xuất thẻ lên Story');
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.ios_share_rounded),
              label: const Text('Chia sẻ lên Story'),
            ),
          ),
        ],
      ),
    );
  }
}
