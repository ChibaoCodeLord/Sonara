import '../models/hum_search_result_model.dart';

enum HumAcousticMode { hum, ambient }

class HumSearchState {
  final bool isRecording;
  final bool isAnalyzing;
  final HumAcousticMode mode;
  final int recordedSeconds;
  final int maxSeconds;
  final List<String> hints;
  final int hintIndex;
  final HumSearchResultModel? result;
  final bool isSnippetPlaying;
  final int snippetSeconds;

  const HumSearchState({
    this.isRecording = true,
    this.isAnalyzing = false,
    this.mode = HumAcousticMode.hum,
    this.recordedSeconds = 7,
    this.maxSeconds = 15,
    this.hints = const [],
    this.hintIndex = 0,
    this.result,
    this.isSnippetPlaying = true,
    this.snippetSeconds = 6,
  });

  String get currentHint =>
      hints.isNotEmpty ? hints[hintIndex % hints.length] : '';

  HumSearchState copyWith({
    bool? isRecording,
    bool? isAnalyzing,
    HumAcousticMode? mode,
    int? recordedSeconds,
    int? maxSeconds,
    List<String>? hints,
    int? hintIndex,
    HumSearchResultModel? result,
    bool? isSnippetPlaying,
    int? snippetSeconds,
  }) {
    return HumSearchState(
      isRecording: isRecording ?? this.isRecording,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      mode: mode ?? this.mode,
      recordedSeconds: recordedSeconds ?? this.recordedSeconds,
      maxSeconds: maxSeconds ?? this.maxSeconds,
      hints: hints ?? this.hints,
      hintIndex: hintIndex ?? this.hintIndex,
      result: result ?? this.result,
      isSnippetPlaying: isSnippetPlaying ?? this.isSnippetPlaying,
      snippetSeconds: snippetSeconds ?? this.snippetSeconds,
    );
  }
}
