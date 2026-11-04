import '../../../core/catalog/catalog_models.dart';
import 'playing_song_model.dart';

extension CatalogSongPlayback on CatalogSong {
  PlayingSongModel toPlayingSong({String contextHint = 'Sonara Catalog'}) {
    return PlayingSongModel(
      id: id,
      title: title,
      artist: artistName,
      coverUrl: coverUrl,
      album: albumTitle,
      durationSeconds: durationSeconds,
      currentSeconds: 0,
      isLossless: true,
      isExplicit: isExplicit,
      isFavorite: false,
      contextHint: contextHint,
    );
  }
}
