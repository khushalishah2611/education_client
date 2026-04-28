import 'dart:convert';

class SelectedCourseData {
  const SelectedCourseData({
    required this.universityKey,
    required this.courseKeys,
  });

  final String universityKey;
  final List<String> courseKeys;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'universityKey': universityKey,
      'courseKeys': courseKeys,
    };
  }

  factory SelectedCourseData.fromJson(Map<String, dynamic> json) {
    return SelectedCourseData(
      universityKey: json['universityKey']?.toString() ?? '',
      courseKeys: (json['courseKeys'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList(),
    );
  }

  String toRawJson() => jsonEncode(toJson());

  factory SelectedCourseData.fromRawJson(String source) {
    final Object? parsed = jsonDecode(source);
    if (parsed is! Map<String, dynamic>) {
      return const SelectedCourseData(
        universityKey: '',
        courseKeys: <String>[],
      );
    }

    return SelectedCourseData.fromJson(parsed);
  }
}
