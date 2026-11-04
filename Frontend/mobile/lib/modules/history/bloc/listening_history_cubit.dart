import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/history_entry_model.dart';
import '../services/history_mock_service.dart';

class ListeningHistoryCubit extends Cubit<List<ListeningHistoryEntry>> {
  ListeningHistoryCubit({HistoryMockService? service})
      : super((service ?? HistoryMockService()).getListeningHistory());

  void remove(String entryId) {
    emit(state.where((e) => e.id != entryId).toList());
  }

  void clearAll() => emit(const []);
}
