import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/downloads_mock_service.dart';
import 'downloads_state.dart';

class DownloadsCubit extends Cubit<DownloadsState> {
  DownloadsCubit({DownloadsMockService? service})
    : super(
        DownloadsState(
          items: (service ?? DownloadsMockService()).getDownloads(),
          cacheMb: (service ?? DownloadsMockService()).getCacheMb(),
        ),
      );

  void remove(String songId) {
    emit(
      state.copyWith(
        items: state.items.where((i) => i.song.id != songId).toList(),
      ),
    );
  }

  void removeAll() => emit(state.copyWith(items: const []));

  void clearCache() => emit(state.copyWith(cacheMb: 0));

  void setQuality(String quality) =>
      emit(state.copyWith(downloadQuality: quality));

  void toggleWifiOnly() => emit(state.copyWith(wifiOnly: !state.wifiOnly));

  void toggleAutoDownloadLiked() =>
      emit(state.copyWith(autoDownloadLiked: !state.autoDownloadLiked));
}
