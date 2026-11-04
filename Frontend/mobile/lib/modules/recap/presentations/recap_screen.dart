import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../core/routes/app_navigator.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../models/recap_model.dart';
import '../services/recap_mock_service.dart';

/// SCR-18: Sonara Recap / Wrapped story slides.
class RecapScreen extends StatefulWidget {
  const RecapScreen({super.key});

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen>
    with SingleTickerProviderStateMixin {
  static const _slideDuration = Duration(seconds: 6);
  static const _palettes = [
    [Color(0xFF5C0A18), Color(0xFFB3122E)],
    [Color(0xFF8B0012), Color(0xFFFF4B4B)],
    [Color(0xFF1A1A1A), Color(0xFF9A1B2F)],
    [Color(0xFF2B4162), Color(0xFFB3122E)],
    [Color(0xFF3F1D38), Color(0xFFE9091F)],
    [Color(0xFF9A1B2F), Color(0xFFFF8A65)],
    [Color(0xFF1A1A1A), Color(0xFF5C0A18)],
  ];

  final RecapModel _recap = RecapMockService().getRecap();
  late final AnimationController _progress;
  int _index = 0;

  int get _slideCount => _palettes.length;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: _slideDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _next();
      })
      ..forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _go(int index) {
    if (index < 0) index = 0;
    if (index >= _slideCount) {
      _progress.stop();
      return;
    }
    setState(() => _index = index);
    _progress.forward(from: 0);
  }

  void _next() => _go(_index + 1);

  @override
  Widget build(BuildContext context) {
    final name = context.read<ProfileCubit>().state.profile.name;
    final colors = _palettes[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final width = MediaQuery.of(context).size.width;
          details.globalPosition.dx < width / 3 ? _go(_index - 1) : _next();
        },
        onLongPressStart: (_) => _progress.stop(),
        onLongPressEnd: (_) => _progress.forward(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) => Row(
                      children: [
                        for (var i = 0; i < _slideCount; i++)
                          Expanded(
                            child: Container(
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: i < _index
                                    ? 1
                                    : i == _index
                                        ? _progress.value
                                        : 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.graphic_eq_rounded, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'Sonara Recap ${_recap.year}',
                        style: AppTextStyles.labelLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Đóng',
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_index),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        child: _buildSlide(_index, name),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(int index, String name) {
    switch (index) {
      case 0:
        return _CenteredSlide(
          eyebrow: 'NĂM ÂM NHẠC CỦA',
          title: name,
          body: 'Cùng nhìn lại những giai điệu đã đồng hành cùng bạn trong năm ${_recap.year}.',
          icon: Icons.celebration_rounded,
        );
      case 1:
        return _CenteredSlide(
          eyebrow: 'BẠN ĐÃ NGHE',
          title: '${_formatNumber(_recap.totalMinutes)} phút',
          body: 'Tương đương ${(_recap.totalMinutes / 1440).toStringAsFixed(0)} ngày liền chỉ có âm nhạc.\n${_recap.topPercentText}.',
          icon: Icons.timer_rounded,
        );
      case 2:
        return _ListSlide(
          title: 'Top 5 bài hát',
          items: [
            for (final song in _recap.topSongs)
              (song.coverUrl, song.title, song.artistName, false),
          ],
        );
      case 3:
        return _ListSlide(
          title: 'Nghệ sĩ thân thiết nhất',
          items: [
            for (final artist in _recap.topArtists)
              (artist.avatarUrl, artist.name, artist.genres.join(' • '), true),
          ],
        );
      case 4:
        return _PersonalitySlide(recap: _recap);
      case 5:
        return _CenteredSlide(
          eyebrow: 'AI HUM-TO-SEARCH',
          title: '${_recap.humCount} lần ngân nga',
          body: 'Giai điệu bạn ngân nga nhiều nhất là "${_recap.mostHummed.title}" của ${_recap.mostHummed.artistName}.',
          icon: Icons.graphic_eq_rounded,
          imageUrl: _recap.mostHummed.coverUrl,
        );
      default:
        return _ShareSlide(recap: _recap, name: name);
    }
  }

  static String _formatNumber(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

class _CenteredSlide extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
  final String? imageUrl;

  const _CenteredSlide({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null)
          AppNetworkImage(
            imageUrl: imageUrl!,
            width: 160,
            height: 160,
            borderRadius: 24,
          )
        else
          Icon(icon, color: Colors.white, size: 64),
        const SizedBox(height: 24),
        Text(
          eyebrow,
          style: AppTextStyles.labelMd.copyWith(
            color: Colors.white70,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTextStyles.displayLg.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 14),
        Text(
          body,
          style: AppTextStyles.bodyLg.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _ListSlide extends StatelessWidget {
  final String title;
  final List<(String, String, String, bool)> items;

  const _ListSlide({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineLg.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    '${i + 1}',
                    style: AppTextStyles.headlineLg.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                AppNetworkImage(
                  imageUrl: items[i].$1,
                  width: items[i].$4 ? 64 : 56,
                  height: items[i].$4 ? 64 : 56,
                  borderRadius: items[i].$4 ? 999 : 10,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headlineSm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        items[i].$3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PersonalitySlide extends StatelessWidget {
  final RecapModel recap;

  const _PersonalitySlide({required this.recap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TÍNH CÁCH ÂM NHẠC DO AI PHÂN TÍCH',
          style: AppTextStyles.labelMd.copyWith(
            color: Colors.white70,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          recap.personalityTitle,
          style: AppTextStyles.displayLgMobile.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          recap.personalityDescription,
          style: AppTextStyles.bodyMd.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 28),
        for (final genre in recap.genres)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      genre.genre,
                      style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      '${(genre.share * 100).round()}%',
                      style: AppTextStyles.labelLg.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: genre.share / recap.genres.first.share,
                    minHeight: 8,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ShareSlide extends StatelessWidget {
  final RecapModel recap;
  final String name;

  const _ShareSlide({required this.recap, required this.name});

  @override
  Widget build(BuildContext context) {
    const targets = [
      (Icons.auto_stories_rounded, 'Instagram'),
      (Icons.facebook_rounded, 'Facebook'),
      (Icons.music_video_rounded, 'TikTok'),
      (Icons.download_rounded, 'Lưu ảnh'),
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$name • Recap ${recap.year}',
                style: AppTextStyles.labelLg.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                recap.personalityTitle,
                style: AppTextStyles.headlineMd.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Stat(
                      label: 'Top bài hát',
                      lines: recap.topSongs.take(3).map((s) => s.title).toList(),
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      label: 'Top nghệ sĩ',
                      lines: recap.topArtists.map((a) => a.name).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _Stat(
                      label: 'Phút nghe',
                      lines: ['${recap.totalMinutes}'],
                      big: true,
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      label: 'Lần AI Hum',
                      lines: ['${recap.humCount}'],
                      big: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Chia sẻ câu chuyện của bạn',
          style: AppTextStyles.labelLg.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final (icon, label) in targets)
              GestureDetector(
                onTap: () => AppNavigator.showMessage(
                  context,
                  label == 'Lưu ảnh'
                      ? 'Đã lưu ảnh story vào thư viện'
                      : 'Đang mở $label Story...',
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: const Color(0xFF9A1B2F)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final List<String> lines;
  final bool big;

  const _Stat({required this.label, required this.lines, this.big = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(color: Colors.white60),
        ),
        const SizedBox(height: 4),
        for (final line in lines)
          Text(
            line,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (big ? AppTextStyles.headlineMd : AppTextStyles.labelLg)
                .copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
      ],
    );
  }
}
