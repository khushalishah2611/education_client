import 'dart:convert';

class AdminUniversity {
  const AdminUniversity({
    required this.id,
    required this.name,
    required this.country,
    required this.state,
    required this.city,
    required this.logoPath,
    required this.rating,
    required this.accredited,
    required this.academicList,
    required this.programLinks,
    required this.courses,
    required this.track,
  });

  factory AdminUniversity.fromJson(Map<String, dynamic> json) {
    return AdminUniversity(
      id: _readString(json, const ['id', '_id']),
      name: _readString(json, const ['name']),
      country: _readString(json, const ['country']),
      state: _readString(json, const ['state']),
      city: _readString(json, const ['city']),
      logoPath: _readString(json, const ['logoPath', 'imagePath', 'logo']),
      rating: _readDouble(json['rating']),
      accredited: _readBool(json, const ['isAccredited', 'accredited']),
      track: _readString(json, const ['track', 'trackType']),
      academicList: (json['academicList'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminAcademicRequirement.fromJson)
          .toList(growable: false),
      programLinks: (json['programLinks'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminProgramLink.fromJson)
          .toList(growable: false),
      courses: (json['courses'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminCourse.fromJson)
          .toList(growable: false),
    );
  }

  final String id;
  final String name;
  final String country;
  final String state;
  final String city;
  final String logoPath;
  final double rating;
  final bool accredited;
  final String track;
  final List<AdminAcademicRequirement> academicList;
  final List<AdminProgramLink> programLinks;
  final List<AdminCourse> courses;
}

class AdminAcademicRequirement {
  const AdminAcademicRequirement({
    required this.academicName,
    required this.college,
    required this.percentage,
  });

  factory AdminAcademicRequirement.fromJson(Map<String, dynamic> json) {
    return AdminAcademicRequirement(
      academicName: _readString(json, const ['academicname', 'academic', 'name']),
      college: _readString(json, const ['college']),
      percentage: _readDouble(json['percentage']),
    );
  }

  final String academicName;
  final String college;
  final double percentage;
}

class AdminProgramLink {
  const AdminProgramLink({required this.program});

  factory AdminProgramLink.fromJson(Map<String, dynamic> json) {
    return AdminProgramLink(
      program: json['program'] is Map<String, dynamic>
          ? AdminProgram.fromJson(json['program'] as Map<String, dynamic>)
          : null,
    );
  }

  final AdminProgram? program;
}

class AdminCourse {
  const AdminCourse({required this.program, required this.track});

  factory AdminCourse.fromJson(Map<String, dynamic> json) {
    return AdminCourse(
      track: _readString(json, const ['track', 'trackType']),
      program: json['program'] is Map<String, dynamic>
          ? AdminProgram.fromJson(json['program'] as Map<String, dynamic>)
          : null,
    );
  }

  final String track;
  final AdminProgram? program;
}

class AdminProgram {
  const AdminProgram({
    required this.name,
    required this.track,
    required this.courseDetails,
  });

  factory AdminProgram.fromJson(Map<String, dynamic> json) {
    return AdminProgram(
      name: _readString(json, const ['name', 'programName', 'courseName']),
      track: _readString(json, const ['track', 'trackType']),
      courseDetails: _parseCourseDetails(json['courseDetails']),
    );
  }

  final String name;
  final String track;
  final List<AdminCourseDetail> courseDetails;
}

class AdminCourseDetail {
  const AdminCourseDetail({required this.name, required this.track});

  factory AdminCourseDetail.fromJson(Map<String, dynamic> json) {
    return AdminCourseDetail(
      name: _readString(json, const ['name']),
      track: _readString(json, const ['track']),
    );
  }

  final String name;
  final String track;
}

List<AdminCourseDetail> _parseCourseDetails(dynamic rawValue) {
  List<dynamic> values = const [];
  if (rawValue is List<dynamic>) {
    values = rawValue;
  } else if (rawValue is String && rawValue.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is List<dynamic>) {
        values = decoded;
      }
    } catch (_) {
      values = const [];
    }
  }

  return values
      .whereType<Map<String, dynamic>>()
      .map(AdminCourseDetail.fromJson)
      .toList(growable: false);
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

bool _readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    if (value is num) return value != 0;
  }
  return false;
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
