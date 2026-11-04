class ChartItemModel {
  final String rank;
  final String title;
  final String artist;
  final int rankDelta; // > 0: up, 0: same, < 0: down
  final String playsText;
  final String imageUrl;
  final bool isLeader;
  final String? badgeLabel;
  final bool isHumHot;

  const ChartItemModel({
    required this.rank,
    required this.title,
    required this.artist,
    required this.rankDelta,
    required this.playsText,
    required this.imageUrl,
    this.isLeader = false,
    this.badgeLabel,
    this.isHumHot = false,
  });
}
