import '../models/chart_item_model.dart';
import '../models/mood_genre_model.dart';
import '../models/spotlight_radar_model.dart';

class ChartsState {
  final String activeTab; // 'vn' vs 'global'
  final String selectedCategory; // 'all', 'hum', 'lossless', 'podcast'
  final List<ChartItemModel> chartItems;
  final SpotlightRadarModel spotlight;
  final List<MoodGenreModel> moodGenres;
  final String lastUpdatedText;

  const ChartsState({
    this.activeTab = 'vn',
    this.selectedCategory = 'all',
    this.chartItems = const [],
    required this.spotlight,
    this.moodGenres = const [],
    this.lastUpdatedText = 'Cập nhật 10 phút trước',
  });

  ChartsState copyWith({
    String? activeTab,
    String? selectedCategory,
    List<ChartItemModel>? chartItems,
    SpotlightRadarModel? spotlight,
    List<MoodGenreModel>? moodGenres,
    String? lastUpdatedText,
  }) {
    return ChartsState(
      activeTab: activeTab ?? this.activeTab,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      chartItems: chartItems ?? this.chartItems,
      spotlight: spotlight ?? this.spotlight,
      moodGenres: moodGenres ?? this.moodGenres,
      lastUpdatedText: lastUpdatedText ?? this.lastUpdatedText,
    );
  }
}
