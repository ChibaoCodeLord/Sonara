import '../models/playlist_model.dart';
import '../models/track_model.dart';
import '../models/chart_track_model.dart';

class HomeState {
  final List<PlaylistModel> aiMixes;
  final List<TrackModel> recommendedTracks;
  final List<ChartTrackModel> trendingCharts;
  final bool isWeeklyChart; // true: Tuần, false: Tháng
  final bool isLoading;

  const HomeState({
    this.aiMixes = const [],
    this.recommendedTracks = const [],
    this.trendingCharts = const [],
    this.isWeeklyChart = true,
    this.isLoading = false,
  });

  HomeState copyWith({
    List<PlaylistModel>? aiMixes,
    List<TrackModel>? recommendedTracks,
    List<ChartTrackModel>? trendingCharts,
    bool? isWeeklyChart,
    bool? isLoading,
  }) {
    return HomeState(
      aiMixes: aiMixes ?? this.aiMixes,
      recommendedTracks: recommendedTracks ?? this.recommendedTracks,
      trendingCharts: trendingCharts ?? this.trendingCharts,
      isWeeklyChart: isWeeklyChart ?? this.isWeeklyChart,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
