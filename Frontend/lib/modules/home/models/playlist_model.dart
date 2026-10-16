class PlaylistModel {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String imageUrl;
  final int listenerCount;

  const PlaylistModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.imageUrl,
    this.listenerCount = 0,
  });
}
