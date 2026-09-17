class ChartTrackModel {
  final String rank;
  final String title;
  final String artist;
  final String plays;
  final int rankDelta; // positive: +x, 0: no change, negative: -x
  final String imageUrl;

  const ChartTrackModel({
    required this.rank,
    required this.title,
    required this.artist,
    required this.plays,
    required this.rankDelta,
    required this.imageUrl,
  });
}
