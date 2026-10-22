import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../core/routes/app_navigator.dart';
import '../../../core/routes/app_router.dart';
import '../../auth/presentations/sign_out_flow.dart';
import '../../player/presentations/sheets/audio_device_sheet.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import 'widgets/ai_acoustic_engine_card.dart';
import 'widgets/preferences_list_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_hero_card.dart';
import 'widgets/profile_quick_links.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();

          return Column(
            children: [
              // Header
              ProfileHeader(
                onSettingsTap: () =>
                    AppNavigator.push(context, AppRouter.settings),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Hero Card
                      ProfileHeroCard(
                        profile: state.profile,
                        onEditProfileTap: () =>
                            AppNavigator.push(context, AppRouter.editProfile),
                      ),
                      const SizedBox(height: 20),

                      // Recap, Premium & shortcuts
                      const ProfileQuickLinks(),
                      const SizedBox(height: 20),

                      // AI Acoustic Intelligence Engine Section
                      AiAcousticEngineCard(
                        settings: state.settings,
                        onSpatialToggle: (val) => cubit.toggleSpatialAudio(val),
                        onVocalToggle: (val) =>
                            cubit.toggleVocalSeparation(val),
                        onSensitivityChanged: (val) =>
                            cubit.setSensitivity(val),
                      ),
                      const SizedBox(height: 20),

                      // Preferences & Connected Ecosystem List
                      PreferencesListCard(
                        settings: state.settings,
                        onThemeChanged: (theme) => cubit.setThemeMode(theme),
                        onHumHistoryTap: () =>
                            AppNavigator.push(context, AppRouter.humHistory),
                        onDevicesTap: () => AudioDeviceSheet.show(context),
                        onEqualizerTap: () =>
                            AppNavigator.push(context, AppRouter.equalizer),
                      ),
                      const SizedBox(height: 20),

                      // Logout button
                      GestureDetector(
                        onTap: () => confirmAndSignOut(context),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCrisp,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x08000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Đăng xuất tài khoản',
                                style: AppTextStyles.labelLg.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // App Version & Neural Core Footer
                      Center(
                        child: Text(
                          'Sonara • Phiên bản 1.0.0',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
