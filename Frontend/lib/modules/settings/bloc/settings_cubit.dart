import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/settings_mock_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsMockService _service;

  SettingsCubit({SettingsMockService? service})
      : _service = service ?? SettingsMockService(),
        super(SettingsState(
          sessions: (service ?? SettingsMockService()).getSessions(),
        ));

  void setWifiQuality(String quality) =>
      emit(state.copyWith(wifiQuality: quality));

  void setCellularQuality(String quality) =>
      emit(state.copyWith(cellularQuality: quality));

  void toggleNewReleases() =>
      emit(state.copyWith(notifyNewReleases: !state.notifyNewReleases));

  void toggleAiPlaylists() =>
      emit(state.copyWith(notifyAiPlaylists: !state.notifyAiPlaylists));

  void toggleNews() => emit(state.copyWith(notifyNews: !state.notifyNews));

  void toggleRecap() => emit(state.copyWith(notifyRecap: !state.notifyRecap));

  void toggleExplicit() =>
      emit(state.copyWith(showExplicit: !state.showExplicit));

  void signOutSession(String sessionId) {
    emit(state.copyWith(
      sessions: state.sessions.where((s) => s.id != sessionId).toList(),
    ));
  }

  void signOutOtherSessions() {
    emit(state.copyWith(
      sessions: state.sessions.where((s) => s.isCurrent).toList(),
    ));
  }

  Future<void> changePassword(String current, String next) =>
      _service.changePassword(current, next);
}
