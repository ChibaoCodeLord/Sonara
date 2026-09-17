import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/acoustic_settings_model.dart';
import '../models/user_profile_model.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit()
      : super(
          const ProfileState(
            profile: UserProfileModel(
              name: 'Lê Hải Đăng',
              avatarUrl:
                  'https://lh3.googleusercontent.com/aida/AEtjO1X3qwyfSRQVs-auxre7zJ1pvmkl_plHcWqsPoWiFZVllOIBbTNSdxuCFpJbEYIdVvGKMjz5IIGghG1q26Ugd8vq4lqAj3UHNH9r84-7EH4kULF1-RqxGB5272qQIqlfdC2ZdkNECgGzKWvLBxwJ_y1Bb_-HkpiJc6Rkuak5rl6UMpR3zpm9jk64V10hO2353MHXFF7EPh22rwaxl3VzDGJwzG88qWYuYoAmYTyZaJIr2QYdC_6a47pkvMZ2',
              vipTier: 'Resonance VIP (Lossless)',
              isVerified: true,
              listeningHours: 480,
              humMatchesCount: 142,
              playlistsCount: 68,
            ),
            settings: AcousticSettingsModel(),
          ),
        );

  void toggleSpatialAudio(bool value) {
    emit(state.copyWith(
      settings: state.settings.copyWith(isSpatialAudio: value),
    ));
  }

  void toggleVocalSeparation(bool value) {
    emit(state.copyWith(
      settings: state.settings.copyWith(isVocalSeparation: value),
    ));
  }

  void setSensitivity(int level) {
    emit(state.copyWith(
      settings: state.settings.copyWith(sensitivityLevel: level),
    ));
  }

  void setThemeMode(String theme) {
    emit(state.copyWith(
      settings: state.settings.copyWith(themeMode: theme),
    ));
  }
}
