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
}
