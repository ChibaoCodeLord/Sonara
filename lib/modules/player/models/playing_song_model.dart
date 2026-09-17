class PlayingSongModel {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String album;
  final int durationSeconds;
  final int currentSeconds;
  final bool isLossless;
  final bool isExplicit;
  final bool isFavorite;
  final String contextHint;

  const PlayingSongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    this.album = 'Album Single (2024)',
    this.durationSeconds = 235,
    this.currentSeconds = 102,
    this.isLossless = true,
    this.isExplicit = true,
    this.isFavorite = true,
    this.contextHint = 'Phát từ gợi ý • AI Hum Match (98%)',
  });

  PlayingSongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? coverUrl,
    String? album,
    int? durationSeconds,
    int? currentSeconds,
    bool? isLossless,
    bool? isExplicit,
    bool? isFavorite,
    String? contextHint,
  }) {
    return PlayingSongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverUrl: coverUrl ?? this.coverUrl,
      album: album ?? this.album,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      isLossless: isLossless ?? this.isLossless,
      isExplicit: isExplicit ?? this.isExplicit,
      isFavorite: isFavorite ?? this.isFavorite,
      contextHint: contextHint ?? this.contextHint,
    );
  }
}
