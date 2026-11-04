import 'package:flutter/material.dart';

class MoodGenreModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isHot;
  final Color dotColor;

  const MoodGenreModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isHot = false,
    required this.dotColor,
  });
}
