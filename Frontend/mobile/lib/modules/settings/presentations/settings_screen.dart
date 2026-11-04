import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/app_bottom_sheet.dart';
import '../../../common/widgets/confirm_dialog.dart';
import '../../../common/widgets/sub_page_header.dart';
import '../../../core/routes/app_navigator.dart';
import '../../../core/routes/app_router.dart';
import '../../auth/presentations/sign_out_flow.dart';
import '../../player/presentations/sheets/audio_device_sheet.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../../profile/bloc/profile_state.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import '../models/session_device_model.dart';
import '../services/settings_mock_service.dart';
import 'sheets/change_password_sheet.dart';

/// SCR-17: App & account settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: Column(
            children: [
              const SubPageHeader(title: 'Cài đặt'),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  children: [
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, profileState) {
                        return _Section(
                          title: 'Tài khoản',
                          children: [
                            _NavRow(
                              icon: Icons.person_outline_rounded,
                              title: 'Chỉnh sửa hồ sơ',
                              subtitle: profileState.profile.email,
                              onTap: () => AppNavigator.push(
                                context,
                                AppRouter.editProfile,
                              ),
                            ),
                            _NavRow(
                              icon: Icons.lock_reset_rounded,
                              title: 'Đổi mật khẩu',
                              subtitle: 'Cập nhật lần cuối 3 tháng trước',
                              onTap: () => ChangePasswordSheet.show(context),
                            ),
                            _NavRow(
                              icon: Icons.workspace_premium_rounded,
                              title: 'Gói cước',
                              subtitle: profileState.profile.vipTier,
                              subtitleColor: AppColors.primary,
                              onTap: () =>
                                  AppNavigator.push(context, AppRouter.premium),
                            ),
                          ],
                        );
                      },
                    ),
                    _Section(
                      title: 'Thiết bị đã đăng nhập',
                      trailing: state.sessions.length > 1
                          ? TextButton(
                              onPressed: () async {
                                final ok = await showConfirmDialog(
                                  context,
                                  title: 'Đăng xuất thiết bị khác?',
                                  message:
                                      'Tất cả thiết bị ngoại trừ thiết bị này sẽ bị đăng xuất.',
                                  confirmLabel: 'Đăng xuất',
                                );
                                if (ok) cubit.signOutOtherSessions();
                              },
                              child: Text(
                                'Đăng xuất tất cả',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                      children: [
                        for (final session in state.sessions)
                          _SessionRow(
                            session: session,
                            onSignOut: () => cubit.signOutSession(session.id),
                          ),
                      ],
                    ),
                    _Section(
                      title: 'Chất lượng phát trực tuyến',
                      children: [
                        _NavRow(
                          icon: Icons.wifi_rounded,
                          title: 'Khi dùng Wi-Fi',
                          subtitle: state.wifiQuality,
                          subtitleColor: AppColors.primary,
                          onTap: () => _pickQuality(
                            context,
                            title: 'Chất lượng qua Wi-Fi',
                            current: state.wifiQuality,
                            onSelected: cubit.setWifiQuality,
                          ),
                        ),
                        _NavRow(
                          icon: Icons.signal_cellular_alt_rounded,
                          title: 'Khi dùng mạng di động 4G/5G',
                          subtitle: state.cellularQuality,
                          subtitleColor: AppColors.primary,
                          onTap: () => _pickQuality(
                            context,
                            title: 'Chất lượng qua 4G/5G',
                            current: state.cellularQuality,
                            onSelected: cubit.setCellularQuality,
                          ),
                        ),
                        _SwitchRow(
                          icon: Icons.explicit_rounded,
                          title: 'Cho phép nội dung Explicit',
                          value: state.showExplicit,
                          onChanged: cubit.toggleExplicit,
                        ),
                      ],
                    ),
                    _Section(
                      title: 'Âm thanh & Thiết bị',
                      children: [
                        _NavRow(
                          icon: Icons.equalizer_rounded,
                          title: 'Bộ chỉnh âm (Equalizer)',
                          subtitle: 'Crossfade, chuẩn hóa âm lượng',
                          onTap: () =>
                              AppNavigator.push(context, AppRouter.equalizer),
                        ),
                        _NavRow(
                          icon: Icons.speaker_group_rounded,
                          title: 'Thiết bị phát',
                          subtitle: 'Bluetooth, AirPlay, Chromecast',
                          onTap: () => AudioDeviceSheet.show(context),
                        ),
                        _NavRow(
                          icon: Icons.download_for_offline_outlined,
                          title: 'Nhạc ngoại tuyến & Bộ nhớ',
                          subtitle: 'Quản lý bản tải và bộ nhớ đệm',
                          onTap: () =>
                              AppNavigator.push(context, AppRouter.offlineMusic),
                        ),
                      ],
                    ),
                    _Section(
                      title: 'Thông báo đẩy',
                      children: [
                        _SwitchRow(
                          icon: Icons.new_releases_outlined,
                          title: 'Nhạc mới từ nghệ sĩ theo dõi',
                          value: state.notifyNewReleases,
                          onChanged: cubit.toggleNewReleases,
                        ),
                        _SwitchRow(
                          icon: Icons.auto_awesome_rounded,
                          title: 'Playlist AI gợi ý hàng tuần',
                          value: state.notifyAiPlaylists,
                          onChanged: cubit.toggleAiPlaylists,
                        ),
                        _SwitchRow(
                          icon: Icons.campaign_outlined,
                          title: 'Tin tức & cập nhật ứng dụng',
                          value: state.notifyNews,
                          onChanged: cubit.toggleNews,
                        ),
                        _SwitchRow(
                          icon: Icons.celebration_outlined,
                          title: 'Sonara Recap định kỳ',
                          value: state.notifyRecap,
                          onChanged: cubit.toggleRecap,
                        ),
                      ],
                    ),
                    _Section(
                      title: 'Khác',
                      children: [
                        _NavRow(
                          icon: Icons.description_outlined,
                          title: 'Điều khoản & Quyền riêng tư',
                          subtitle: 'Cập nhật 01/2026',
                          onTap: () => AppNavigator.showMessage(
                            context,
                            'Đang mở điều khoản dịch vụ...',
                          ),
                        ),
                        _NavRow(
                          icon: Icons.info_outline_rounded,
                          title: 'Về Sonara',
                          subtitle: 'Phiên bản 1.0.0',
                          onTap: () => showAboutDialog(
                            context: context,
                            applicationName: 'Sonara',
                            applicationVersion: '1.0.0',
                            applicationLegalese: '© 2026 Sonara • PBL6',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => confirmAndSignOut(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.borderMuted),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickQuality(
    BuildContext context, {
    required String title,
    required String current,
    required ValueChanged<String> onSelected,
  }) {
    showAppBottomSheet<void>(
      context: context,
      title: title,
      subtitle: 'Chất lượng cao hơn sẽ dùng nhiều dữ liệu hơn',
      builder: (sheetContext) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (final option in SettingsMockService.qualityOptions)
            SheetActionTile(
              icon: Icons.graphic_eq_rounded,
              label: option,
              color: option == current ? AppColors.primary : null,
              trailing: option == current
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                onSelected(option);
                Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  const _Section({required this.title, required this.children, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: AppTextStyles.labelSm.copyWith(
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCrisp,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 58,
                      color: AppColors.borderSubtle,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textCharcoal, size: 22),
            const SizedBox(width: 22),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm.copyWith(
                      color: subtitleColor ?? AppColors.textMuted,
                      fontWeight: subtitleColor == null
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final VoidCallback onChanged;

  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 8, 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textCharcoal, size: 22),
          const SizedBox(width: 22),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final SessionDeviceModel session;
  final VoidCallback onSignOut;

  const _SessionRow({required this.session, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final lower = session.name.toLowerCase();
    final icon = lower.contains('tv')
        ? Icons.tv_rounded
        : lower.contains('mac') || lower.contains('web')
            ? Icons.laptop_mac_rounded
            : lower.contains('ipad')
                ? Icons.tablet_mac_rounded
                : Icons.smartphone_rounded;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textCharcoal, size: 22),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.location} • ${session.lastActive}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm.copyWith(
                    color: session.isCurrent
                        ? AppColors.emeraldActive
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (session.isCurrent)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'Thiết bị này',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.emeraldActive,
                ),
              ),
            )
          else
            TextButton(
              onPressed: onSignOut,
              child: Text(
                'Đăng xuất',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
