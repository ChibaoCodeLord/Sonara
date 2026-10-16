class RecentHumHistoryModel {
  final String id;
  final String title;
  final String artist;
  final String matchPercentage;
  final String timeAgo;
  final String coverUrl;

  const RecentHumHistoryModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.matchPercentage,
    required this.timeAgo,
    required this.coverUrl,
  });
}
