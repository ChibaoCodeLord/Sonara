import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_bottom_sheet.dart';
import '../../../core/routes/app_navigator.dart';
import '../../../core/routes/app_router.dart';
import '../../auth/presentations/sign_out_flow.dart';
import '../../player/presentations/sheets/audio_device_sheet.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_hero_card.dart';
import 'widgets/profile_menu.dart';
import 'widgets/profile_recap_banner.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _sensitivityNames = ['Tiết kiệm', 'Tiêu chuẩn', 'Ultra Clean'];
  static const _themeNames = {
    'light': 'Sáng',
    'dark': 'Tối',
    'system': 'Theo hệ thống',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          final settings = state.settings;
          void open(String route) => AppNavigator.push(context, route);

          return Column(
            children: [
              ProfileHeader(onSettingsTap: () => open(AppRouter.settings)),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 200),
                  children: [
                    ProfileHeroCard(
                      profile: state.profile,
                      onEditProfileTap: () => open(AppRouter.editProfile),
                      onPlanTap: () => open(AppRouter.premium),
                    ),
                    const SizedBox(height: 24),
                    ProfileRecapBanner(onTap: () => open(AppRouter.recap)),
                    const SizedBox(height: 28),
                    ProfileMenuSection(
                      title: 'Hoạt động',
                      children: [
                        ProfileMenuRow(
                          icon: Icons.history_rounded,
                          title: 'Nghe gần đây',
                          onTap: () => open(AppRouter.listeningHistory),
                        ),
                        ProfileMenuRow(
                          icon: Icons.graphic_eq_rounded,
                          title: 'Lịch sử AI Hum',
                          value: '${state.profile.humMatchesCount} bản ghi',
                          onTap: () => open(AppRouter.humHistory),
                        ),
                        ProfileMenuRow(
                          icon: Icons.download_for_offline_outlined,
                          title: 'Nhạc đã tải',
                          onTap: () => open(AppRouter.offlineMusic),
                        ),
                        ProfileMenuRow(
                          icon: Icons.qr_code_scanner_rounded,
                          title: 'Quét Wave Code',
                          onTap: () => open(AppRouter.waveCodeScanner),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ProfileMenuSection(
                      title: 'Hiệu ứng âm thanh',
                      children: [
                        ProfileMenuRow.toggle(
                          icon: Icons.surround_sound_rounded,
                          title: 'Sonara Spatial 3D',
                          value: settings.isSpatialAudio,
                          onChanged: cubit.toggleSpatialAudio,
                        ),
                        ProfileMenuRow.toggle(
                          icon: Icons.mic_external_on_rounded,
                          title: 'Tách vocal (Karaoke)',
                          value: settings.isVocalSeparation,
                          onChanged: cubit.toggleVocalSeparation,
                        ),
                        ProfileMenuRow(
                          icon: Icons.hearing_rounded,
                          title: 'Độ nhạy mic AI Hum',
                          value:
                              _sensitivityNames[settings.sensitivityLevel - 1],
                          onTap: () => _showSensitivitySheet(context),
                        ),
                        ProfileMenuRow(
                          icon: Icons.equalizer_rounded,
                          title: 'Bộ chỉnh âm',
                          value: settings.equalizerProfile
                              .replaceFirst('Profile: ', ''),
                          onTap: () => open(AppRouter.equalizer),
                        ),
                        ProfileMenuRow(
                          icon: Icons.headphones_rounded,
                          title: 'Thiết bị phát',
                          value: settings.pairedDevice.split(' • ').first,
                          onTap: () => AudioDeviceSheet.show(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ProfileMenuSection(
                      title: 'Ứng dụng',
                      children: [
                        ProfileMenuRow(
                          icon: Icons.dark_mode_outlined,
                          title: 'Giao diện',
                          value: _themeNames[settings.themeMode],
                          onTap: () => _showThemeSheet(context),
                        ),
                        ProfileMenuRow(
                          icon: Icons.settings_outlined,
                          title: 'Cài đặt',
                          onTap: () => open(AppRouter.settings),
                        ),
                        ProfileMenuRow(
                          icon: Icons.logout_rounded,
                          title: 'Đăng xuất',
                          color: AppColors.primary,
                          trailing: const SizedBox.shrink(),
                          onTap: () => confirmAndSignOut(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Sonara • Phiên bản 1.0.0',
                        style: AppTextStyles.labelSm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSensitivitySheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      title: 'Độ nhạy mic AI Hum',
      subtitle: 'Mức cao lọc tạp âm tốt hơn nhưng tốn pin hơn',
      builder: (_) => BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final level = state.settings.sensitivityLevel;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.settings.sensitivityLabel,
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Slider(
                  value: level.toDouble(),
                  min: 1,
                  max: 3,
                  divisions: 2,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.surfaceContainerHigh,
                  onChanged: (v) =>
                      context.read<ProfileCubit>().setSensitivity(v.round()),
                ),
                Row(
                  children: [
                    for (var i = 0; i < _sensitivityNames.length; i++)
                      Expanded(
                        child: Text(
                          _sensitivityNames[i],
                          textAlign: i == 0
                              ? TextAlign.left
                              : i == 2
                                  ? TextAlign.right
                                  : TextAlign.center,
                          style: AppTextStyles.labelSm.copyWith(
                            color: level == i + 1
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontWeight: level == i + 1
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showThemeSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      title: 'Giao diện',
      builder: (sheetContext) => BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) => ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            for (final entry in _themeNames.entries)
              SheetActionTile(
                icon: switch (entry.key) {
                  'light' => Icons.light_mode_outlined,
                  'dark' => Icons.dark_mode_outlined,
                  _ => Icons.brightness_auto_outlined,
                },
                label: entry.value,
                color: state.settings.themeMode == entry.key
                    ? AppColors.primary
                    : null,
                trailing: state.settings.themeMode == entry.key
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  context.read<ProfileCubit>().setThemeMode(entry.key);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
