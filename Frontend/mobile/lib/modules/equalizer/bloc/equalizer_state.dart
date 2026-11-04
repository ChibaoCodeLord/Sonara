import '../models/eq_preset_model.dart';

class EqualizerState {
  final bool isEnabled;
  final List<EqPresetModel> presets;
  final String selectedPresetId; // 'custom' once a band is dragged
  final List<double> gains;
  final bool isTenBand;
  final double crossfadeSeconds;
  final bool normalizeVolume;
  final bool gaplessPlayback;

  const EqualizerState({
    this.isEnabled = true,
    this.presets = const [],
    this.selectedPresetId = 'warmth',
    this.gains = const [],
    this.isTenBand = true,
    this.crossfadeSeconds = 5,
    this.normalizeVolume = true,
    this.gaplessPlayback = true,
  });

  String get presetName {
    for (final preset in presets) {
      if (preset.id == selectedPresetId) return preset.name;
    }
    return 'Tùy chỉnh';
  }

  EqualizerState copyWith({
    bool? isEnabled,
    List<EqPresetModel>? presets,
    String? selectedPresetId,
    List<double>? gains,
    bool? isTenBand,
    double? crossfadeSeconds,
    bool? normalizeVolume,
    bool? gaplessPlayback,
  }) {
    return EqualizerState(
      isEnabled: isEnabled ?? this.isEnabled,
      presets: presets ?? this.presets,
      selectedPresetId: selectedPresetId ?? this.selectedPresetId,
      gains: gains ?? this.gains,
      isTenBand: isTenBand ?? this.isTenBand,
      crossfadeSeconds: crossfadeSeconds ?? this.crossfadeSeconds,
      normalizeVolume: normalizeVolume ?? this.normalizeVolume,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
    );
  }
}
