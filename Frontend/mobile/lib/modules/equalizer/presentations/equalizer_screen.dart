import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/gradient_button.dart';
import '../../../common/widgets/sub_page_header.dart';
import '../../../core/routes/app_navigator.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../bloc/equalizer_cubit.dart';
import '../bloc/equalizer_state.dart';
import '../services/equalizer_mock_service.dart';
import 'widgets/eq_band_panel.dart';

/// SCR-12: Graphic equalizer, crossfade and loudness normalization.
class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EqualizerCubit(),
      child: BlocBuilder<EqualizerCubit, EqualizerState>(
        builder: (context, state) {
          final cubit = context.read<EqualizerCubit>();
          final visibleGains = state.isTenBand
              ? state.gains
              : [for (var i = 0; i < 5; i++) state.gains[i * 2]];
          final labels = state.isTenBand
              ? EqualizerMockService.bandLabels
              : const ['60', '230', '910', '3.6K', '14K'];

          return Scaffold(
            backgroundColor: AppColors.surface,
            body: Column(
              children: [
                SubPageHeader(
                  title: 'Sonara EQ',
                  actions: [
                    Switch(
                      value: state.isEnabled,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      onChanged: (_) => cubit.toggleEnabled(),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Đang dùng',
                                  style: AppTextStyles.labelSm,
                                ),
                                Text(
                                  state.presetName,
                                  style: AppTextStyles.headlineMd.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _BandModeToggle(
                            isTenBand: state.isTenBand,
                            onChanged: cubit.setTenBand,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      EqBandPanel(
                        gains: visibleGains,
                        labels: labels,
                        enabled: state.isEnabled,
                        onChanged: cubit.setBand,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Preset',
                              style: AppTextStyles.headlineSm.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: cubit.reset,
                            icon: const Icon(
                              Icons.restart_alt_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            label: Text(
                              'Đặt lại',
                              style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final preset in state.presets)
                            ChoiceChip(
                              label: Text(preset.name),
                              selected: preset.id == state.selectedPresetId,
                              onSelected: state.isEnabled
                                  ? (_) => cubit.selectPreset(preset.id)
                                  : null,
                              showCheckmark: false,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surfaceCrisp,
                              side: const BorderSide(
                                color: AppColors.borderMuted,
                              ),
                              labelStyle: AppTextStyles.labelMd.copyWith(
                                color: preset.id == state.selectedPresetId
                                    ? Colors.white
                                    : AppColors.textCharcoal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Chuyển bài & Âm lượng',
                        style: AppTextStyles.headlineSm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.swap_horiz_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Crossfade',
                                        style: AppTextStyles.labelLg.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'Chuyển bài mượt, không khoảng lặng',
                                        style: AppTextStyles.bodySm,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  state.crossfadeSeconds == 0
                                      ? 'Tắt'
                                      : '${state.crossfadeSeconds.round()} giây',
                                  style: AppTextStyles.labelLg.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Slider(
                            value: state.crossfadeSeconds,
                            min: 0,
                            max: 12,
                            divisions: 12,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.surfaceContainer,
                            onChanged: cubit.setCrossfade,
                          ),
                          const Divider(
                            height: 1,
                            indent: 52,
                            color: AppColors.borderSubtle,
                          ),
                          _SwitchRow(
                            icon: Icons.volume_up_rounded,
                            title: 'Chuẩn hóa âm lượng',
                            subtitle: 'Giữ mức âm lượng đồng đều giữa các bài',
                            value: state.normalizeVolume,
                            onChanged: (_) => cubit.toggleNormalize(),
                          ),
                          const Divider(
                            height: 1,
                            indent: 52,
                            color: AppColors.borderSubtle,
                          ),
                          _SwitchRow(
                            icon: Icons.linear_scale_rounded,
                            title: 'Phát liền mạch (Gapless)',
                            subtitle: 'Dành cho album live & concept album',
                            value: state.gaplessPlayback,
                            onChanged: (_) => cubit.toggleGapless(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        label: 'Áp dụng cấu hình',
                        icon: Icons.check_rounded,
                        onPressed: () {
                          context.read<ProfileCubit>().setEqualizerProfile(
                                'Profile: ${state.presetName}',
                              );
                          AppNavigator.showMessage(
                            context,
                            'Đã áp dụng EQ "${state.presetName}"',
                          );
                          Navigator.of(context).pop();
                        },
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

class _BandModeToggle extends StatelessWidget {
  final bool isTenBand;
  final ValueChanged<bool> onChanged;

  const _BandModeToggle({required this.isTenBand, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget option(String label, bool value) {
      final selected = isTenBand == value;
      return GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceCrisp : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: selected ? AppColors.primary : AppColors.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [option('5-band', false), option('10-band', true)],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCrisp,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(subtitle, style: AppTextStyles.bodySm),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
