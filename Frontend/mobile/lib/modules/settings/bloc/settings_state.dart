import '../models/session_device_model.dart';

class SettingsState {
  final String wifiQuality;
  final String cellularQuality;
  final bool notifyNewReleases;
  final bool notifyAiPlaylists;
  final bool notifyNews;
  final bool notifyRecap;
  final bool showExplicit;
  final List<SessionDeviceModel> sessions;

  const SettingsState({
    this.wifiQuality = 'Hi-Res • FLAC 24-bit/192kHz',
    this.cellularQuality = 'Cao • 320kbps',
    this.notifyNewReleases = true,
    this.notifyAiPlaylists = true,
    this.notifyNews = false,
    this.notifyRecap = true,
    this.showExplicit = true,
    this.sessions = const [],
  });

  SettingsState copyWith({
    String? wifiQuality,
    String? cellularQuality,
    bool? notifyNewReleases,
    bool? notifyAiPlaylists,
    bool? notifyNews,
    bool? notifyRecap,
    bool? showExplicit,
    List<SessionDeviceModel>? sessions,
  }) {
    return SettingsState(
      wifiQuality: wifiQuality ?? this.wifiQuality,
      cellularQuality: cellularQuality ?? this.cellularQuality,
      notifyNewReleases: notifyNewReleases ?? this.notifyNewReleases,
      notifyAiPlaylists: notifyAiPlaylists ?? this.notifyAiPlaylists,
      notifyNews: notifyNews ?? this.notifyNews,
      notifyRecap: notifyRecap ?? this.notifyRecap,
      showExplicit: showExplicit ?? this.showExplicit,
      sessions: sessions ?? this.sessions,
    );
  }
}
