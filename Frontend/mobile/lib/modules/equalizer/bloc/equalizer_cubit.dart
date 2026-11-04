import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/equalizer_mock_service.dart';
import 'equalizer_state.dart';

class EqualizerCubit extends Cubit<EqualizerState> {
  EqualizerCubit({EqualizerMockService? service})
      : super(_initialState(service ?? EqualizerMockService()));

  static EqualizerState _initialState(EqualizerMockService service) {
    final presets = service.getPresets();
    return EqualizerState(
      presets: presets,
      selectedPresetId: presets.first.id,
      gains: presets.first.gains,
    );
  }

  void toggleEnabled() {
    emit(state.copyWith(isEnabled: !state.isEnabled));
  }

  void selectPreset(String presetId) {
    final preset = state.presets.firstWhere((p) => p.id == presetId);
    emit(state.copyWith(selectedPresetId: presetId, gains: preset.gains));
  }

  /// Sets a band gain. In 5-band mode each visible band drives a pair of
  /// the underlying 10 bands.
  void setBand(int index, double gain) {
    final gains = [...state.gains];
    if (state.isTenBand) {
      gains[index] = gain;
    } else {
      gains[index * 2] = gain;
      gains[index * 2 + 1] = gain;
    }
    emit(state.copyWith(gains: gains, selectedPresetId: 'custom'));
  }

  void setTenBand(bool value) {
    emit(state.copyWith(isTenBand: value));
  }

  void reset() {
    selectPreset('flat');
  }

  void setCrossfade(double seconds) {
    emit(state.copyWith(crossfadeSeconds: seconds));
  }

  void toggleNormalize() {
    emit(state.copyWith(normalizeVolume: !state.normalizeVolume));
  }

  void toggleGapless() {
    emit(state.copyWith(gaplessPlayback: !state.gaplessPlayback));
  }
}
