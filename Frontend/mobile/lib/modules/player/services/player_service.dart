import '../../../core/catalog/catalog_models.dart';
import '../../../core/catalog/music_catalog.dart';
import '../models/audio_device_model.dart';
import '../models/catalog_song_playback.dart';
import '../models/lyric_line_model.dart';
import '../models/playing_song_model.dart';

class PlayerService {
  PlayingSongModel getDefaultPlayingSong() {
    return const PlayingSongModel(
      id: 'song_bau_troi_moi',
      title: 'Bầu Trời Mới',
      artist: 'Da LAB, Miu Lê',
      coverUrl: 'assets/images/bau_troi_moi.jpg',
      album: 'Album Single (2024)',
      durationSeconds: 235, // 03:55 total (01:42 current, 02:13 remaining)
      currentSeconds: 102,
      isLossless: true,
      isExplicit: true,
      isFavorite: true,
      contextHint: 'AI Hum Match (98%)',
    );
  }

  List<LyricLineModel> getLyricsForSong(String songId) {
    return const [
      LyricLineModel(
        timeSeconds: 90,
        text: 'Dù mai này ta có bước tiếp bên nhau hay không...',
        isCurrent: false,
      ),
      LyricLineModel(
        timeSeconds: 102,
        text:
            'Hãy hứa với anh rằng em sẽ tìm được một bầu trời mới thật bình yên.',
        isCurrent: true,
      ),
      LyricLineModel(
        timeSeconds: 118,
        text: 'Nơi không còn những nỗi buồn vương trên đôi mi gầy...',
        isCurrent: false,
      ),
    ];
  }

  List<PlayingSongModel> getDefaultQueue() {
    const ids = [
      'song_duoi_anh_hoang_hon',
      'song_co_doi_lan',
      'song_ngay_dau_tien',
      'song_mua_tren_tang_thuong',
      'song_khoa_anh_mat_lai',
    ];
    return ids
        .map(MusicCatalog.songById)
        .whereType<CatalogSong>()
        .map((song) => song.toPlayingSong(contextHint: 'Hàng đợi • Up Next'))
        .toList();
  }

  List<LyricLineModel> getFullLyrics(String songId) {
    const lines = [
      'Đêm nay phố vắng, đèn vàng hắt lên ô cửa nhỏ',
      'Anh ngồi lặng im, nghe mưa rơi trên mái phố cũ',
      'Bao nhiêu câu hát, ta từng ngân nga chung lối về',
      'Giờ chỉ còn anh, với giai điệu chưa thành lời...',
      'Dù mai này ta có bước tiếp bên nhau hay không...',
      'Hãy hứa với anh rằng em sẽ tìm được một bầu trời mới thật bình yên.',
      'Nơi không còn những nỗi buồn vương trên đôi mi gầy...',
      'Nơi nắng sớm gọi tên em qua từng khung cửa',
      'Và gió sẽ hát thay anh những điều chưa kịp nói',
      'Bầu trời mới, xanh như ngày đầu ta gặp gỡ',
      'Bầu trời mới, cho em bình yên đến cuối con đường',
      'Còn anh, giữ lại giai điệu này... mãi thôi.',
    ];
    const times = [12, 28, 44, 62, 90, 102, 118, 134, 150, 172, 192, 214];
    return [
      for (var i = 0; i < lines.length; i++)
        LyricLineModel(timeSeconds: times[i], text: lines[i]),
    ];
  }

  List<AudioDeviceModel> getAudioDevices() {
    return const [
      AudioDeviceModel(
        id: 'airpods',
        name: 'AirPods Pro',
        detail: 'Bluetooth • Hi-Fi LDAC • Pin 82%',
        type: AudioDeviceType.headphones,
      ),
      AudioDeviceModel(
        id: 'phone',
        name: 'Loa điện thoại',
        detail: 'Thiết bị này',
        type: AudioDeviceType.phone,
      ),
      AudioDeviceModel(
        id: 'living_room',
        name: 'Loa phòng khách',
        detail: 'Wi-Fi • AirPlay 2',
        type: AudioDeviceType.speaker,
      ),
      AudioDeviceModel(
        id: 'tv',
        name: 'Smart TV Phòng ngủ',
        detail: 'Wi-Fi • Chromecast',
        type: AudioDeviceType.tv,
      ),
      AudioDeviceModel(
        id: 'car',
        name: 'Xe hơi • CarPlay',
        detail: 'Đã kết nối lần cuối hôm qua',
        type: AudioDeviceType.car,
      ),
    ];
  }
}
