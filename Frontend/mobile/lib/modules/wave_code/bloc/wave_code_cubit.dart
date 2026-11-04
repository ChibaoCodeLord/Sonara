import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/catalog/music_catalog.dart';
import 'wave_code_state.dart';

/// Simulated Wave Code scanning until a camera plugin is integrated.
class WaveCodeCubit extends Cubit<WaveCodeState> {
  static const Duration scanDelay = Duration(milliseconds: 2600);

  Timer? _scanTimer;

  WaveCodeCubit() : super(const WaveCodeState()) {
    startScan();
  }

  void startScan() {
    _scanTimer?.cancel();
    emit(WaveCodeState(isFlashOn: state.isFlashOn));
    _scanTimer = Timer(scanDelay, () {
      final songs = MusicCatalog.songs;
      final song = songs[math.Random().nextInt(songs.length)];
      emit(state.copyWith(status: WaveScanStatus.detected, detectedSong: song));
    });
  }

  void setShowMyCode(bool value) {
    emit(state.copyWith(showMyCode: value));
    if (!value && state.status != WaveScanStatus.detected) startScan();
  }

  void toggleFlash() => emit(state.copyWith(isFlashOn: !state.isFlashOn));

  @override
  Future<void> close() {
    _scanTimer?.cancel();
    return super.close();
  }
}
