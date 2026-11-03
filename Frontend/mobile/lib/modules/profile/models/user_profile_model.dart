class UserProfileModel {
  final String name;
  final String avatarUrl;
  final String vipTier;
  final bool isVerified;
  final int listeningHours;
  final int humMatchesCount;
  final int playlistsCount;

  const UserProfileModel({
    required this.name,
    required this.avatarUrl,
    required this.vipTier,
    this.isVerified = true,
    required this.listeningHours,
    required this.humMatchesCount,
    required this.playlistsCount,
  });
}
