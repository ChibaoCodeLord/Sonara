class TrackModel {
  final String id;
  final String title;
  final String artist;
  final String matchPercentage;
  final String imageUrl;
  final bool isFavorite;
  final String? audioUrl;
  final String? album;

  const TrackModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.matchPercentage,
    required this.imageUrl,
    this.isFavorite = false,
    this.audioUrl,
    this.album,
  });

  TrackModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? matchPercentage,
    String? imageUrl,
    bool? isFavorite,
    String? audioUrl,
    String? album,
  }) {
    return TrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      audioUrl: audioUrl ?? this.audioUrl,
      album: album ?? this.album,
    );
  }
}
