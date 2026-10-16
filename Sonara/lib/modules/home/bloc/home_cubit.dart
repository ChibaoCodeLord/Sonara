import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/home_mock_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeMockService _service;

  HomeCubit({HomeMockService? service})
      : _service = service ?? HomeMockService(),
        super(const HomeState()) {
    loadHomeData();
  }

  void loadHomeData() {
    emit(state.copyWith(isLoading: true));
    final mixes = _service.getAiMixes();
    final tracks = _service.getRecommendedTracks();
    final charts = _service.getTrendingCharts();
    emit(state.copyWith(
      aiMixes: mixes,
      recommendedTracks: tracks,
      trendingCharts: charts,
      isLoading: false,
    ));
  }

  void toggleFavorite(String trackId) {
    final updated = state.recommendedTracks.map((track) {
      if (track.id == trackId) {
        return track.copyWith(isFavorite: !track.isFavorite);
      }
      return track;
    }).toList();
    emit(state.copyWith(recommendedTracks: updated));
  }

  void setChartTimeframe(bool isWeekly) {
    emit(state.copyWith(isWeeklyChart: isWeekly));
  }
}
