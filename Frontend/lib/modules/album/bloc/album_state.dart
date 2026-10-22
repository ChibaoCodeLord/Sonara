import '../../../core/catalog/catalog_models.dart';

class AlbumState {
  final CatalogAlbum album;
  final List<CatalogSong> tracks;
  final List<CatalogAlbum> moreAlbums;
  final bool isSaved;
  final bool isDownloaded;
  final double downloadProgress; // 0..1 while downloading

  const AlbumState({
    required this.album,
    this.tracks = const [],
    this.moreAlbums = const [],
    this.isSaved = false,
    this.isDownloaded = false,
    this.downloadProgress = 0,
  });

  bool get isDownloading => downloadProgress > 0 && downloadProgress < 1;

  int get totalSeconds =>
      tracks.fold(0, (sum, track) => sum + track.durationSeconds);

  AlbumState copyWith({
    bool? isSaved,
    bool? isDownloaded,
    double? downloadProgress,
  }) {
    return AlbumState(
      album: album,
      tracks: tracks,
      moreAlbums: moreAlbums,
      isSaved: isSaved ?? this.isSaved,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}
