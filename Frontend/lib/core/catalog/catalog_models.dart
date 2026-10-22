import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class CatalogSong {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String albumId;
  final String albumTitle;
  final String coverUrl;
  final int durationSeconds;
  final String playsText;
  final String quality; // 'LOSSLESS', 'HI-RES'
  final bool isExplicit;

  const CatalogSong({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    required this.albumId,
    required this.albumTitle,
    required this.coverUrl,
    required this.durationSeconds,
    required this.playsText,
    this.quality = 'LOSSLESS',
    this.isExplicit = false,
  });

  String get durationText => Formatters.formatSeconds(durationSeconds);
}

class CatalogArtist {
  final String id;
  final String name;
  final String avatarUrl;
  final String coverUrl;
  final String monthlyListenersText;
  final String followersText;
  final String bio;
  final List<String> genres;
  final bool isVerified;

  const CatalogArtist({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.coverUrl,
    required this.monthlyListenersText,
    required this.followersText,
    required this.bio,
    this.genres = const [],
    this.isVerified = true,
  });
}

class CatalogAlbum {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String coverUrl;
  final int year;
  final String label;
  final String type; // 'Album', 'Single', 'EP'
  final String quality;
  final List<String> songIds;

  const CatalogAlbum({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    required this.coverUrl,
    required this.year,
    required this.label,
    required this.type,
    this.quality = 'FLAC 24-bit / 96kHz',
    required this.songIds,
  });
}

class CatalogPlaylist {
  final String id;
  final String title;
  final String subtitle;
  final String coverUrl;

  const CatalogPlaylist({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coverUrl,
  });
}

class CatalogCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const CatalogCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}
