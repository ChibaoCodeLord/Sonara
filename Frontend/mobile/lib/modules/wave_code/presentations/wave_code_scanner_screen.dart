import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/wave_code.dart';
import '../../../core/routes/app_navigator.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/models/catalog_song_playback.dart';
import '../bloc/wave_code_cubit.dart';
import '../bloc/wave_code_state.dart';

/// SCR-19: Scan a friend's Sonara Wave Code, or show your own.
class WaveCodeScannerScreen extends StatelessWidget {
  const WaveCodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WaveCodeCubit(),
      child: BlocBuilder<WaveCodeCubit, WaveCodeState>(
        builder: (context, state) {
          final cubit = context.read<WaveCodeCubit>();
          return Scaffold(
            backgroundColor: const Color(0xFF0E0E10),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Đóng',
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            'Sonara Wave Code',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headlineSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Đèn flash',
                          icon: Icon(
                            state.isFlashOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            color: state.isFlashOn
                                ? const Color(0xFFFFD54F)
                                : Colors.white,
                          ),
                          onPressed: state.showMyCode ? null : cubit.toggleFlash,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ModeSwitch(
                    showMyCode: state.showMyCode,
                    onChanged: cubit.setShowMyCode,
                  ),
                  Expanded(
                    child: state.showMyCode
                        ? const _MyCodeView()
                        : _ScannerView(state: state),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  final bool showMyCode;
  final ValueChanged<bool> onChanged;

  const _ModeSwitch({required this.showMyCode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget option(String label, bool value) {
      final selected = showMyCode == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelLg.copyWith(
                color: selected ? AppColors.primary : Colors.white70,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [option('Quét mã', false), option('Mã của tôi', true)],
      ),
    );
  }
}

class _ScannerView extends StatefulWidget {
  final WaveCodeState state;

  const _ScannerView({required this.state});

  @override
  State<_ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<_ScannerView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanLine;

  @override
  void initState() {
    super.initState();
    _scanLine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final detected = state.status == WaveScanStatus.detected;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: RadialGradient(
                  colors: state.isFlashOn
                      ? const [Color(0xFF5A5A5E), Color(0xFF2A2A2E)]
                      : const [Color(0xFF2A2A2E), Color(0xFF151517)],
                ),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(child: _ViewfinderCorners()),
                  if (!detected)
                    AnimatedBuilder(
                      animation: _scanLine,
                      builder: (context, _) => Align(
                        alignment: Alignment(0, _scanLine.value * 1.6 - 0.8),
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 36),
                          decoration: BoxDecoration(
                            color: AppColors.aiGradientEnd,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.aiGradientEnd
                                    .withValues(alpha: 0.6),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: detected ? 1 : 0.35,
                      child: WaveCode(
                        data: state.detectedSong?.id ?? 'scanning',
                        height: 54,
                        color: detected ? AppColors.primary : Colors.white,
                        background: detected ? Colors.white : Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (!detected) ...[
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Đưa Wave Code vào khung hình để quét',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: Colors.white70),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => AppNavigator.showMessage(
                context,
                'Đang mở thư viện ảnh...',
              ),
              icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
              label: Text(
                'Quét từ ảnh trong máy',
                style: AppTextStyles.labelLg.copyWith(color: Colors.white),
              ),
            ),
          ] else
            _DetectedCard(state: state),
        ],
      ),
    );
  }
}

class _DetectedCard extends StatelessWidget {
  final WaveCodeState state;

  const _DetectedCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final song = state.detectedSong!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCrisp,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AppNetworkImage(
                imageUrl: song.coverUrl,
                width: 56,
                height: 56,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ĐÃ NHẬN DIỆN MÃ',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSm.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      song.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.read<WaveCodeCubit>().startScan(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textCharcoal,
                    side: const BorderSide(color: AppColors.borderMuted),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Quét lại'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    context.read<PlayerCubit>().playSong(
                          song.toPlayingSong(contextHint: 'Wave Code từ bạn bè'),
                        );
                    navigator.pop();
                    AppNavigator.openNowPlaying(navigator.context);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Nghe ngay'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyCodeView extends StatelessWidget {
  const _MyCodeView();

  @override
  Widget build(BuildContext context) {
    final song = context.read<PlayerCubit>().state.song;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                AppNetworkImage(
                  imageUrl: song.coverUrl,
                  width: 200,
                  height: 200,
                  borderRadius: 20,
                ),
                const SizedBox(height: 16),
                Text(
                  song.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMd.copyWith(color: Colors.white),
                ),
                Text(
                  song.artist,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                WaveCode(
                  data: song.id,
                  height: 60,
                  color: AppColors.primary,
                  background: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cho bạn bè quét mã này để nghe ngay bài hát bạn đang phát.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ViewfinderCorners extends StatelessWidget {
  const _ViewfinderCorners();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CornerPainter());
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const inset = 28.0;
    const length = 34.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final corners = [
      (const Offset(inset, inset), 1.0, 1.0),
      (Offset(size.width - inset, inset), -1.0, 1.0),
      (Offset(inset, size.height - inset), 1.0, -1.0),
      (Offset(size.width - inset, size.height - inset), -1.0, -1.0),
    ];
    for (final (point, dx, dy) in corners) {
      canvas.drawLine(point, point + Offset(length * dx, 0), paint);
      canvas.drawLine(point, point + Offset(0, length * dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
