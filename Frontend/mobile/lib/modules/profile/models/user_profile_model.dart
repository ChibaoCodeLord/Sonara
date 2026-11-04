class UserProfileModel {
  final String name;
  final String avatarUrl;
  final String vipTier;
  final bool isVerified;
  final int listeningHours;
  final int humMatchesCount;
  final int playlistsCount;
  final String email;
  final String bio;

  const UserProfileModel({
    required this.name,
    required this.avatarUrl,
    required this.vipTier,
    this.isVerified = true,
    required this.listeningHours,
    required this.humMatchesCount,
    required this.playlistsCount,
    this.email = 'haidang@sonara.vn',
    this.bio = 'Người săn giai điệu bằng tiếng huýt sáo 🎶',
  });

  UserProfileModel copyWith({
    String? name,
    String? avatarUrl,
    String? vipTier,
    String? email,
    String? bio,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      vipTier: vipTier ?? this.vipTier,
      isVerified: isVerified,
      listeningHours: listeningHours,
      humMatchesCount: humMatchesCount,
      playlistsCount: playlistsCount,
      email: email ?? this.email,
      bio: bio ?? this.bio,
    );
  }
}
