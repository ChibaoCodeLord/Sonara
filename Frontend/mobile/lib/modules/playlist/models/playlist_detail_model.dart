class PlaylistTrackItemModel {
  final String id;
  final int index;
  final String title;
  final String artist;
  final String durationText;
  final String qualityBadge; // 'LOSSLESS', 'HI-RES'
  final String matchPercentage; // '98% Khớp gu'
  final String coverUrl;

  const PlaylistTrackItemModel({
    required this.id,
    required this.index,
    required this.title,
    required this.artist,
    required this.durationText,
    required this.qualityBadge,
    required this.matchPercentage,
    required this.coverUrl,
  });
}

class PlaylistDetailModel {
  final String id;
  final String title;
  final String engineTag;
  final String description;
  final String coverUrl;
  final String emotionAnalysis;
  final List<PlaylistTrackItemModel> tracks;

  const PlaylistDetailModel({
    required this.id,
    required this.title,
    required this.engineTag,
    required this.description,
    required this.coverUrl,
    required this.emotionAnalysis,
    required this.tracks,
  });
}
