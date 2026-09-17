import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/pulsing_dot.dart';
import '../../../core/utils/formatters.dart';
import '../bloc/hum_search_cubit.dart';
import '../bloc/hum_search_state.dart';
import 'hum_search_result_screen.dart';
import 'widgets/animated_mic_visualizer.dart';
import 'widgets/hint_rotator_card.dart';
import 'widgets/mode_segmented_switch.dart';

class HumToSearchScreen extends StatelessWidget {
  const HumToSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HumSearchCubit, HumSearchState>(
      listener: (context, state) {
        if (state.result != null && !state.isAnalyzing) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<HumSearchCubit>(),
                child: const HumSearchResultScreen(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<HumSearchCubit>();
        final progress = (state.recordedSeconds / state.maxSeconds).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Top Header
                _buildHeader(context),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      children: [
                        // Status & Quality Pills
                        _buildStatusRow(),
                        const SizedBox(height: 12),

                        // Central Animated Mic & 19-Bar Equalizer
                        AnimatedMicVisualizer(
                          onMicTap: () => cubit.stopAndAnalyze(),
                        ),
                        const SizedBox(height: 14),

                        // Timer & Progress Track
                        _buildTimerProgress(state.recordedSeconds, state.maxSeconds, progress),
                        const SizedBox(height: 22),

                        // Guidance Hint Card
                        HintRotatorCard(
                          hintText: state.currentHint,
                        ),
                        const SizedBox(height: 22),

                        // Mode Switcher (Hum vs Ambient)
                        ModeSegmentedSwitch(
                          currentMode: state.mode,
                          onModeChanged: (mode) => cubit.switchMode(mode),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons: Analyze & Cancel
                        _buildBottomActions(context, cubit, state.isAnalyzing),
                        const SizedBox(height: 16),
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

  Widget _buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PulsingDot(
                color: AppColors.aiGradientEnd,
                size: 7,
              ),
              const SizedBox(width: 8),
              Text(
                'AI ENGINE 2.4 ACTIVE',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                '96kHz / 32-bit',
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerProgress(int recorded, int max, double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Formatters.formatSeconds(recorded),
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '/ ${Formatters.formatSeconds(max)}',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 190,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.miniPlayerProgressGradient,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, HumSearchCubit cubit, bool isAnalyzing) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: isAnalyzing ? null : () => cubit.stopAndAnalyze(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: isAnalyzing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.troubleshoot_rounded, size: 20),
            label: Text(
              isAnalyzing ? 'Đang phân tích...' : 'Dừng & Phân tích ngay',
              style: AppTextStyles.labelLg.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'Hủy bỏ',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.textCharcoal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
