import '../models/lyric_line_model.dart';
import '../models/playing_song_model.dart';

class PlayerService {
  PlayingSongModel getDefaultPlayingSong() {
    return const PlayingSongModel(
      id: 'song_bau_troi_moi',
      title: 'Bầu Trời Mới',
      artist: 'Da LAB, Miu Lê',
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB2pv8cLoliC1o0qBT0hHaT5sXrWNQtyO7hj2l8f5s6HU7WC2c6IJyCUcx_JoQE71NomvmSfAuxf0VFaaQUMvWlxMSzbCfKx2hPsqQueX5SRSVKIDTg3Du5y4Bfr-LEo6Vdgia9IIaTjl_sL8-abyd_G_dYZhX9ARcc83JNzV8kfyLkyH9PAb2VDK1sdwBnOOSm7_DK2PjYAkrA3BOosqxvnJd_W--Rj-MdxcwnrSJOvrBv73qR_yk1ww',
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
        text: 'Hãy hứa với anh rằng em sẽ tìm được một bầu trời mới thật bình yên.',
        isCurrent: true,
      ),
      LyricLineModel(
        timeSeconds: 118,
        text: 'Nơi không còn những nỗi buồn vương trên đôi mi gầy...',
        isCurrent: false,
      ),
    ];
  }
}
