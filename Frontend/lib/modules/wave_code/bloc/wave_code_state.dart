import '../../../core/catalog/catalog_models.dart';

enum WaveScanStatus { scanning, detected }

class WaveCodeState {
  final bool showMyCode;
  final WaveScanStatus status;
  final bool isFlashOn;
  final CatalogSong? detectedSong;

  const WaveCodeState({
    this.showMyCode = false,
    this.status = WaveScanStatus.scanning,
    this.isFlashOn = false,
    this.detectedSong,
  });

  WaveCodeState copyWith({
    bool? showMyCode,
    WaveScanStatus? status,
    bool? isFlashOn,
    CatalogSong? detectedSong,
  }) {
    return WaveCodeState(
      showMyCode: showMyCode ?? this.showMyCode,
      status: status ?? this.status,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      detectedSong: detectedSong ?? this.detectedSong,
    );
  }
}
