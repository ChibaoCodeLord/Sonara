class LibraryPlaylistModel {
  final String id;
  final String title;
  final String creator;
  final int trackCount;
  final String coverUrl;
  final String badgeType; // 'ai_mood', 'auto_mix', 'user_created'
  final String badgeLabel;
  final String description;
  final bool isPublic;
  final bool isCollaborative;

  const LibraryPlaylistModel({
    required this.id,
    required this.title,
    required this.creator,
    required this.trackCount,
    required this.coverUrl,
    required this.badgeType,
    required this.badgeLabel,
    this.description = '',
    this.isPublic = true,
    this.isCollaborative = false,
  });

  LibraryPlaylistModel copyWith({
    String? title,
    int? trackCount,
    String? coverUrl,
    String? badgeLabel,
    String? description,
    bool? isPublic,
    bool? isCollaborative,
  }) {
    return LibraryPlaylistModel(
      id: id,
      title: title ?? this.title,
      creator: creator,
      trackCount: trackCount ?? this.trackCount,
      coverUrl: coverUrl ?? this.coverUrl,
      badgeType: badgeType,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      isCollaborative: isCollaborative ?? this.isCollaborative,
    );
  }
}
