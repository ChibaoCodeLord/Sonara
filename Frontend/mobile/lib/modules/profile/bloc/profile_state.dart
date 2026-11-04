import '../models/acoustic_settings_model.dart';
import '../models/user_profile_model.dart';

class ProfileState {
  final UserProfileModel profile;
  final AcousticSettingsModel settings;

  const ProfileState({
    required this.profile,
    required this.settings,
  });

  ProfileState copyWith({
    UserProfileModel? profile,
    AcousticSettingsModel? settings,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
    );
  }
}
