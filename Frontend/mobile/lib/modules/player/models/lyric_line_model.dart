class LyricLineModel {
  final int timeSeconds;
  final String text;
  final bool isCurrent;

  const LyricLineModel({
    required this.timeSeconds,
    required this.text,
    this.isCurrent = false,
  });

  LyricLineModel copyWith({
    int? timeSeconds,
    String? text,
    bool? isCurrent,
  }) {
    return LyricLineModel(
      timeSeconds: timeSeconds ?? this.timeSeconds,
      text: text ?? this.text,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}
