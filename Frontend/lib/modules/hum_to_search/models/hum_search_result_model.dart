class SongMatchModel {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String album;
  final int matchPercentage;
  final String matchReason;
  final String detectionSegment;
  final String timeRange;
  final bool isTop1;
  final bool isFavorite;

  const SongMatchModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.album,
    required this.matchPercentage,
    this.matchReason = 'Trùng khớp cao độ giọng hát',
    this.detectionSegment = 'Điệp khúc',
    this.timeRange = '01:15 - 01:28',
    this.isTop1 = false,
    this.isFavorite = false,
  });

  SongMatchModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? coverUrl,
    String? album,
    int? matchPercentage,
    String? matchReason,
    String? detectionSegment,
    String? timeRange,
    bool? isTop1,
    bool? isFavorite,
  }) {
    return SongMatchModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverUrl: coverUrl ?? this.coverUrl,
      album: album ?? this.album,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      matchReason: matchReason ?? this.matchReason,
      detectionSegment: detectionSegment ?? this.detectionSegment,
      timeRange: timeRange ?? this.timeRange,
      isTop1: isTop1 ?? this.isTop1,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class HumSearchResultModel {
  final int confidenceScore;
  final SongMatchModel bestMatch;
  final List<SongMatchModel> otherCandidates;

  const HumSearchResultModel({
    required this.confidenceScore,
    required this.bestMatch,
    required this.otherCandidates,
  });
}
