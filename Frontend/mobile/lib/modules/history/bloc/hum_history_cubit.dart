import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/history_entry_model.dart';
import '../services/history_mock_service.dart';

class HumHistoryState {
  final List<HumHistoryEntry> entries;
  final String filter; // 'all', 'hum', 'whistle'

  const HumHistoryState({this.entries = const [], this.filter = 'all'});

  List<HumHistoryEntry> get visible => filter == 'all'
      ? entries
      : entries.where((e) => e.mode == filter).toList();

  int get averageMatch => entries.isEmpty
      ? 0
      : (entries.fold<int>(0, (sum, e) => sum + e.matchPercentage) /
              entries.length)
          .round();

  HumHistoryState copyWith({List<HumHistoryEntry>? entries, String? filter}) {
    return HumHistoryState(
      entries: entries ?? this.entries,
      filter: filter ?? this.filter,
    );
  }
}

class HumHistoryCubit extends Cubit<HumHistoryState> {
  HumHistoryCubit({HistoryMockService? service})
      : super(HumHistoryState(
          entries: (service ?? HistoryMockService()).getHumHistory(),
        ));

  void setFilter(String filter) => emit(state.copyWith(filter: filter));

  void remove(String entryId) {
    emit(state.copyWith(
      entries: state.entries.where((e) => e.id != entryId).toList(),
    ));
  }

  void clearAll() => emit(state.copyWith(entries: const []));
}
