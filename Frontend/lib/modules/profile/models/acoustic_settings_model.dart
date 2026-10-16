class AcousticSettingsModel {
  final bool isSpatialAudio;
  final bool isVocalSeparation;
  final int sensitivityLevel; // 1: Tiết kiệm 44.1kHz, 2: Tiêu chuẩn 48kHz, 3: Ultra Clean 96kHz
  final String streamingQuality;
  final String pairedDevice;
  final String equalizerProfile;
  final String themeMode; // 'light', 'dark', 'system'

  const AcousticSettingsModel({
    this.isSpatialAudio = true,
    this.isVocalSeparation = true,
    this.sensitivityLevel = 3,
    this.streamingQuality = 'Hi-Res FLAC • 24-bit / 192kHz',
    this.pairedDevice = 'AirPods Pro 2 • Hi-Fi LDAC',
    this.equalizerProfile = 'Profile: Vocal Dynamic Warmth',
    this.themeMode = 'system',
  });

  AcousticSettingsModel copyWith({
    bool? isSpatialAudio,
    bool? isVocalSeparation,
    int? sensitivityLevel,
    String? streamingQuality,
    String? pairedDevice,
    String? equalizerProfile,
    String? themeMode,
  }) {
    return AcousticSettingsModel(
      isSpatialAudio: isSpatialAudio ?? this.isSpatialAudio,
      isVocalSeparation: isVocalSeparation ?? this.isVocalSeparation,
      sensitivityLevel: sensitivityLevel ?? this.sensitivityLevel,
      streamingQuality: streamingQuality ?? this.streamingQuality,
      pairedDevice: pairedDevice ?? this.pairedDevice,
      equalizerProfile: equalizerProfile ?? this.equalizerProfile,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  String get sensitivityLabel {
    switch (sensitivityLevel) {
      case 1:
        return '44.1kHz (Tiết kiệm Pin)';
      case 2:
        return '48kHz / 24-bit (Tiêu chuẩn)';
      case 3:
      default:
        return '96kHz / 32-bit (Tối ưu)';
    }
  }
}
