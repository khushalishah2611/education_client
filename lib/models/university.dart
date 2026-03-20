import 'package:flutter/material.dart';

class University {
  const University({
    required this.name,
    required this.location,
    required this.rating,
    required this.shortCode,
    required this.themeColor,
    required this.accentColor,
    required this.ranking,
    required this.intake,
    required this.degreeInfo,
    required this.about,
  });

  final String name;
  final String location;
  final double rating;
  final String shortCode;
  final Color themeColor;
  final Color accentColor;
  final String ranking;
  final String intake;
  final String degreeInfo;
  final String about;
}
