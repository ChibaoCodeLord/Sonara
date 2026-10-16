class FollowingArtistModel {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isVerified;
  final bool hasNewUpdate;

  const FollowingArtistModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isVerified = false,
    this.hasNewUpdate = false,
  });
}
