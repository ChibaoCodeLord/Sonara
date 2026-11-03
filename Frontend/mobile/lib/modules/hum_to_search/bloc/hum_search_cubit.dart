import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/hum_search_result_model.dart';
import '../services/hum_search_service.dart';
import 'hum_search_state.dart';

class HumSearchCubit extends Cubit<HumSearchState> {
  final HumSearchService _service;
  Timer? _timer;
  Timer? _hintTimer;

  HumSearchCubit({HumSearchService? service})
      : _service = service ?? HumSearchService(),
        super(HumSearchState(
          hints: (service ?? HumSearchService()).getGuidanceHints(),
        )) {
    startListening();
  }

  void startListening() {
    _timer?.cancel();
    _hintTimer?.cancel();

    emit(state.copyWith(
      isRecording: true,
      isAnalyzing: false,
      recordedSeconds: 7,
      hintIndex: 0,
      result: null,
    ));

    // Progress timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.recordedSeconds < state.maxSeconds) {
        emit(state.copyWith(recordedSeconds: state.recordedSeconds + 1));
      } else {
        stopAndAnalyze();
      }
    });

    // Hint rotation timer
    _hintTimer = Timer.periodic(const Duration(milliseconds: 3800), (timer) {
      emit(state.copyWith(hintIndex: state.hintIndex + 1));
    });
  }

  void switchMode(HumAcousticMode mode) {
    emit(state.copyWith(mode: mode));
  }

  void stopAndAnalyze() {
    _timer?.cancel();
    _hintTimer?.cancel();
    emit(state.copyWith(isRecording: false, isAnalyzing: true));

    // Simulate AI inference delay of 600ms
    Future.delayed(const Duration(milliseconds: 600), () {
      final result = _service.getMockSearchResult();
      emit(state.copyWith(
        isAnalyzing: false,
        result: result,
        isSnippetPlaying: true,
        snippetSeconds: 6,
      ));
    });
  }

  void toggleSnippetPlay() {
    emit(state.copyWith(isSnippetPlaying: !state.isSnippetPlaying));
  }

  void toggleFavorite(String songId) {
    if (state.result == null) return;
    final best = state.result!.bestMatch;
    if (best.id == songId) {
      final updatedBest = best.copyWith(isFavorite: !best.isFavorite);
      emit(state.copyWith(
        result: HumSearchResultModel(
          confidenceScore: state.result!.confidenceScore,
          bestMatch: updatedBest,
          otherCandidates: state.result!.otherCandidates,
        ),
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _hintTimer?.cancel();
    return super.close();
  }
}
