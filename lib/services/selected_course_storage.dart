import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin_university.dart';

class SelectedCourseStorage {
  static const String _key = 'pending_selected_course';

  static Future<void> save({
    required AdminUniversity university,
    required CourseDetails course,
    String? collegeName,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> payload = <String, dynamic>{
      'universityId': university.id,
      'universityName': university.name,
      'universityAddress': university.address,
      'universityImage': university.coverImagePath,
      'collegeName': collegeName,
      'course': course.toJson(),
    };
    await prefs.setString(_key, jsonEncode(payload));
  }

  static Future<SelectedCourseData?> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return SelectedCourseData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class SelectedCourseData {
  final String universityId;
  final String universityName;
  final String universityAddress;
  final String universityImage;
  final String collegeName;
  final CourseDetails course;

  const SelectedCourseData({
    required this.universityId,
    required this.universityName,
    required this.universityAddress,
    required this.universityImage,
    required this.collegeName,
    required this.course,
  });

  factory SelectedCourseData.fromJson(Map<String, dynamic> json) {
    return SelectedCourseData(
      universityId: json['universityId']?.toString() ?? '',
      universityName: json['universityName']?.toString() ?? '',
      universityAddress: json['universityAddress']?.toString() ?? '',
      universityImage: json['universityImage']?.toString() ?? '',
      collegeName: json['collegeName']?.toString() ?? '',
      course: CourseDetails.fromJson(
        (json['course'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
    );
  }
}
