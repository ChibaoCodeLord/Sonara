class LibraryPlaylistModel {
  final String id;
  final String title;
  final String creator;
  final int trackCount;
  final String coverUrl;
  final String badgeType; // 'ai_mood', 'auto_mix', 'user_created'
  final String badgeLabel;

  const LibraryPlaylistModel({
    required this.id,
    required this.title,
    required this.creator,
    required this.trackCount,
    required this.coverUrl,
    required this.badgeType,
    required this.badgeLabel,
  });
}
