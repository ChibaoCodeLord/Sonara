import 'package:flutter/material.dart';

class OnboardingSlideModel {
  final String title;
  final String description;
  final IconData icon;
  final String badge;

  const OnboardingSlideModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.badge,
  });
}
