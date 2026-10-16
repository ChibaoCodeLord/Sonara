import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/charts_mock_service.dart';
import 'charts_state.dart';

class ChartsCubit extends Cubit<ChartsState> {
  final ChartsMockService _service;

  ChartsCubit({ChartsMockService? service})
      : _service = service ?? ChartsMockService(),
        super(ChartsState(
          chartItems: (service ?? ChartsMockService()).getVnChartItems(),
          spotlight: (service ?? ChartsMockService()).getSpotlightRadar(),
          moodGenres: (service ?? ChartsMockService()).getMoodGenres(),
        ));

  void switchTab(String tab) {
    if (tab == state.activeTab) return;
    final items = tab == 'vn'
        ? _service.getVnChartItems()
        : _service.getGlobalChartItems();
    emit(state.copyWith(activeTab: tab, chartItems: items));
  }

  void selectCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }
}
