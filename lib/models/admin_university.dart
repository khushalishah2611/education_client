import 'dart:convert';

double? _toDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

dynamic _decodeJsonString(dynamic value) {
  if (value is! String) {
    return value;
  }

  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return value;
  }

  final startsLikeJson = trimmed.startsWith('[') || trimmed.startsWith('{');
  if (!startsLikeJson) {
    return value;
  }

  try {
    return jsonDecode(trimmed);
  } catch (_) {
    return value;
  }
}

List<dynamic>? _toDynamicList(dynamic value) {
  final decoded = _decodeJsonString(value);
  return decoded is List ? decoded : null;
}

Map<String, dynamic>? _toStringDynamicMap(dynamic value) {
  final decoded = _decodeJsonString(value);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  if (decoded is Map) {
    return decoded.map(
      (key, value) => MapEntry(key.toString(), value),
    );
  }
  return null;
}

List<String>? _toStringList(dynamic value) {
  final decoded = _decodeJsonString(value);
  if (decoded == null) {
    return null;
  }
  if (decoded is List) {
    return decoded
        .map(_toTrimmedString)
        .whereType<String>()
        .toList(growable: false);
  }
  final text = _toTrimmedString(decoded);
  if (text == null) {
    return null;
  }
  return text
      .split(RegExp(r'[\n;,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String? _toTrimmedString(dynamic value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

List<String> _splitCourseNames(dynamic value) {
  if (value == null) {
    return <String>[];
  }
  if (value is List) {
    return value
        .map(_toTrimmedString)
        .whereType<String>()
        .toList(growable: false);
  }
  return value
      .toString()
      .split(RegExp(r'[\n,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

List<AcademicPrograms>? _academicProgramsFromAcademicList(
  List<AcademicList>? academicList,
) {
  if (academicList == null || academicList.isEmpty) {
    return null;
  }

  final Map<String, AcademicPrograms> groupedPrograms =
      <String, AcademicPrograms>{};

  for (final AcademicList entry in academicList) {
    final Program? program = entry.program;
    final String academicName = _toTrimmedString(entry.academicname) ??
        _toTrimmedString(program?.academicProgram) ??
        _toTrimmedString(program?.name) ??
        '';
    final String collegeName = _toTrimmedString(entry.college) ??
        _toTrimmedString(program?.educationInstitute) ??
        '';

    if (academicName.isEmpty && collegeName.isEmpty && program == null) {
      continue;
    }

    final AcademicPrograms academicProgram = groupedPrograms.putIfAbsent(
      academicName,
      () => AcademicPrograms(
        academicname: academicName,
        colleges: <Colleges>[],
      ),
    );

    final List<Colleges> colleges = academicProgram.colleges ?? <Colleges>[];
    academicProgram.colleges = colleges;

    final Colleges college = colleges.firstWhere(
      (item) => (item.college ?? '') == collegeName,
      orElse: () {
        final created = Colleges(college: collegeName, courses: <Courses>[]);
        colleges.add(created);
        return created;
      },
    );

    final List<Courses> courses = college.courses ?? <Courses>[];
    college.courses = courses;

    final List<CourseDetails> details =
        program?.courseDetails ?? <CourseDetails>[];
    if (details.isNotEmpty) {
      courses.addAll(
        details.map(
          (course) => Courses.fromCourseDetails(
            course,
            program: program,
            academicName: academicName,
            collegeName: collegeName,
          ),
        ),
      );
      continue;
    }

    final dynamic courseNames = program?.courses?.isNotEmpty == true
        ? program?.courses
        : program?.courseNames;
    for (final String courseName in _splitCourseNames(courseNames)) {
      courses.add(
        Courses.fromCourseDetails(
          CourseDetails(name: courseName),
          program: program,
          academicName: academicName,
          collegeName: collegeName,
        ),
      );
    }
  }

  return groupedPrograms.values.toList(growable: false);
}

class AdminUniversity {
  String? id;
  String? name;
  String? country;
  String? state;
  String? city;
  String? email;
  String? mobile;
  double? rating;
  List<AcademicList>? academicList;
  String? logoPath;
  String? coverImagePath;
  String? address;
  String? aboutUs;
  bool? accredited;
  String? status;
  bool? isEnabled;
  String? createdAt;
  String? updatedAt;
  List<ProgramLinks>? programLinks;
  List<Ratings>? ratings;
  double? averageRating;
  double? ratingCount;
  List<AcademicPrograms>? academicPrograms;

  AdminUniversity(
      {this.id,
      this.name,
      this.country,
      this.state,
      this.city,
      this.email,
      this.mobile,
      this.rating,
      this.academicList,
      this.logoPath,
      this.coverImagePath,
      this.address,
      this.aboutUs,
      this.accredited,
      this.status,
      this.isEnabled,
      this.createdAt,
      this.updatedAt,
      this.programLinks,
      this.ratings,
      this.averageRating,
      this.ratingCount,
      this.academicPrograms});

  AdminUniversity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    country = json['country'];
    state = json['state'];
    city = json['city'];
    email = json['email'];
    mobile = json['mobile'];
    rating = _toDouble(json['rating']);
    final academicListJson = _toDynamicList(json['academicList']);
    if (academicListJson != null) {
      academicList = <AcademicList>[];
      for (final item in academicListJson) {
        final itemJson = _toStringDynamicMap(item);
        if (itemJson != null) {
          academicList!.add(AcademicList.fromJson(itemJson));
        }
      }
    }
    logoPath = json['logoPath'];
    coverImagePath = json['coverImagePath'];
    address = json['address'];
    aboutUs = json['aboutUs'];
    accredited = json['accredited'];
    status = json['status'];
    isEnabled = json['isEnabled'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    final programLinksJson = _toDynamicList(json['programLinks']);
    if (programLinksJson != null) {
      programLinks = <ProgramLinks>[];
      for (final item in programLinksJson) {
        final itemJson = _toStringDynamicMap(item);
        if (itemJson != null) {
          programLinks!.add(ProgramLinks.fromJson(itemJson));
        }
      }
    }
    final ratingsJson = _toDynamicList(json['ratings']);
    if (ratingsJson != null) {
      ratings = <Ratings>[];
      for (final item in ratingsJson) {
        final itemJson = _toStringDynamicMap(item);
        if (itemJson != null) {
          ratings!.add(Ratings.fromJson(itemJson));
        }
      }
    }
    averageRating = _toDouble(json['averageRating']);
    ratingCount = _toDouble(json['ratingCount']);
    final academicProgramsJson = _toDynamicList(json['academicPrograms']);
    if (academicProgramsJson != null) {
      academicPrograms = <AcademicPrograms>[];
      for (final item in academicProgramsJson) {
        final itemJson = _toStringDynamicMap(item);
        if (itemJson != null) {
          academicPrograms!.add(AcademicPrograms.fromJson(itemJson));
        }
      }
    }
    if (academicPrograms == null || academicPrograms!.isEmpty) {
      academicPrograms = _academicProgramsFromAcademicList(academicList);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['country'] = this.country;
    data['state'] = this.state;
    data['city'] = this.city;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['rating'] = this.rating;
    if (this.academicList != null) {
      data['academicList'] = this.academicList!.map((v) => v.toJson()).toList();
    }
    data['logoPath'] = this.logoPath;
    data['coverImagePath'] = this.coverImagePath;
    data['address'] = this.address;
    data['aboutUs'] = this.aboutUs;
    data['accredited'] = this.accredited;
    data['status'] = this.status;
    data['isEnabled'] = this.isEnabled;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.programLinks != null) {
      data['programLinks'] = this.programLinks!.map((v) => v.toJson()).toList();
    }
    if (this.ratings != null) {
      data['ratings'] = this.ratings!.map((v) => v.toJson()).toList();
    }
    data['averageRating'] = this.averageRating;
    data['ratingCount'] = this.ratingCount;
    if (this.academicPrograms != null) {
      data['academicPrograms'] =
          this.academicPrograms!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AcademicList {
  String? academicname;
  String? college;
  Program? program;

  AcademicList({this.academicname, this.college, this.program});

  AcademicList.fromJson(Map<String, dynamic> json) {
    academicname = json['academicname'];
    college = json['college'];
    final programJson = _toStringDynamicMap(json['program']);
    program = programJson != null ? Program.fromJson(programJson) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['academicname'] = this.academicname;
    data['college'] = this.college;
    if (this.program != null) {
      data['program'] = this.program!.toJson();
    }
    return data;
  }
}

class Program {
  String? id;
  String? name;
  String? academicProgram;
  String? courseNames;
  List<CourseDetails>? courseDetails;
  String? track;
  dynamic description;
  dynamic durationMonths;
  double? minAdmissionRate;
  String? minBaGpa;
  dynamic requiredScore;
  dynamic discountedScore;
  String? status;
  bool? isEnabled;
  double? basePrice;
  String? currency;
  double? commissionPercent;
  dynamic coverImagePath;
  List<String>? eligibilityTitle;
  List<String>? scholarshipInfoTitle;
  String? createdAt;
  String? updatedAt;
  List<UniversityLinks>? universityLinks;
  String? educationInstitute;
  List<String>? courses;

  Program(
      {this.id,
      this.name,
      this.academicProgram,
      this.courseNames,
      this.courseDetails,
      this.track,
      this.description,
      this.durationMonths,
      this.minAdmissionRate,
      this.minBaGpa,
      this.requiredScore,
      this.discountedScore,
      this.status,
      this.isEnabled,
      this.basePrice,
      this.currency,
      this.commissionPercent,
      this.coverImagePath,
      this.eligibilityTitle,
      this.scholarshipInfoTitle,
      this.createdAt,
      this.updatedAt,
      this.universityLinks,
      this.educationInstitute,
      this.courses});

  Program.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    academicProgram = json['academicProgram'];
    courseNames = json['courseNames'];
    final courseDetailsJson = _toDynamicList(json['courseDetails']);
    if (courseDetailsJson != null) {
      courseDetails = <CourseDetails>[];
      for (final item in courseDetailsJson) {
        final itemJson = _toStringDynamicMap(item);
        if (itemJson != null) {
          courseDetails!.add(CourseDetails.fromJson(itemJson));
        }
      }
    }
    track = json['track'];
    description = json['description'];
    durationMonths = json['durationMonths'];
    minAdmissionRate = _toDouble(json['minAdmissionRate']);
    minBaGpa = json['minBaGpa'];
    requiredScore = json['requiredScore'];
    discountedScore = json['discountedScore'];
    status = json['status'];
    isEnabled = json['isEnabled'];
    basePrice = _toDouble(json['basePrice']);
    currency = json['currency'];
    commissionPercent = _toDouble(json['commissionPercent']);
    coverImagePath = json['coverImagePath'];
    eligibilityTitle = _toStringList(json['eligibilityTitle']);
    scholarshipInfoTitle = _toStringList(json['scholarshipInfoTitle']);
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    final universityLinksJson = _toDynamicList(json['universityLinks']);
    if (universityLinksJson != null) {
      universityLinks = <UniversityLinks>[];
      for (final item in universityLinksJson) {
        final itemJson = _toStringDynamicMap(item);
        if (itemJson != null) {
          universityLinks!.add(UniversityLinks.fromJson(itemJson));
        }
      }
    }
    educationInstitute = json['educationInstitute'];
    courses = _toStringList(json['courses']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['academicProgram'] = this.academicProgram;
    data['courseNames'] = this.courseNames;
    if (this.courseDetails != null) {
      data['courseDetails'] =
          this.courseDetails!.map((v) => v.toJson()).toList();
    }
    data['track'] = this.track;
    data['description'] = this.description;
    data['durationMonths'] = this.durationMonths;
    data['minAdmissionRate'] = this.minAdmissionRate;
    data['minBaGpa'] = this.minBaGpa;
    data['requiredScore'] = this.requiredScore;
    data['discountedScore'] = this.discountedScore;
    data['status'] = this.status;
    data['isEnabled'] = this.isEnabled;
    data['basePrice'] = this.basePrice;
    data['currency'] = this.currency;
    data['commissionPercent'] = this.commissionPercent;
    data['coverImagePath'] = this.coverImagePath;
    data['eligibilityTitle'] = this.eligibilityTitle;
    data['scholarshipInfoTitle'] = this.scholarshipInfoTitle;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.universityLinks != null) {
      data['universityLinks'] =
          this.universityLinks!.map((v) => v.toJson()).toList();
    }
    data['educationInstitute'] = this.educationInstitute;
    data['courses'] = this.courses;
    return data;
  }
}

class CourseDetails {
  String? name;
  bool? isBooked;
  String? track;
  String? duration;
  double? creditHours;
  double? totalFees;
  double? semesters;
  double? totalSemesters;
  double? feePerCredit;
  double? semesterFee;
  double? annualFee;
  double? basePrice;
  double? minAdmissionRate;
  List<String>? eligibility;
  List<String>? otherRequirements;
  String? currency;
  double? applicationFee;
  String? status;
  String? minBaGpa;

  CourseDetails(
      {this.name,
      this.isBooked,
      this.track,
      this.duration,
      this.creditHours,
      this.totalFees,
      this.semesters,
      this.totalSemesters,
      this.feePerCredit,
      this.semesterFee,
      this.annualFee,
      this.basePrice,
      this.minAdmissionRate,
      this.eligibility,
      this.otherRequirements,
      this.currency,
      this.applicationFee,
      this.status,
      this.minBaGpa});

  CourseDetails.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    isBooked = json['isBooked'];
    track = json['track'];
    duration = json['duration'];
    creditHours = _toDouble(json['creditHours']);
    totalFees = _toDouble(json['totalFees']);
    semesters = _toDouble(json['semesters']);
    totalSemesters = _toDouble(json['totalSemesters']);
    feePerCredit = _toDouble(json['feePerCredit']);
    semesterFee = _toDouble(json['semesterFee']);
    annualFee = _toDouble(json['annualFee']);
    basePrice = _toDouble(json['basePrice']);
    minAdmissionRate = _toDouble(json['minAdmissionRate']);
    eligibility = _toStringList(json['eligibility']);
    otherRequirements = _toStringList(json['otherRequirements']);
    currency = json['currency'];
    applicationFee = _toDouble(json['applicationFee']);
    status = json['status'];
    minBaGpa = json['minBaGpa'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['isBooked'] = this.isBooked;
    data['track'] = this.track;
    data['duration'] = this.duration;
    data['creditHours'] = this.creditHours;
    data['totalFees'] = this.totalFees;
    data['semesters'] = this.semesters;
    data['totalSemesters'] = this.totalSemesters;
    data['feePerCredit'] = this.feePerCredit;
    data['semesterFee'] = this.semesterFee;
    data['annualFee'] = this.annualFee;
    data['basePrice'] = this.basePrice;
    data['minAdmissionRate'] = this.minAdmissionRate;
    data['eligibility'] = this.eligibility;
    data['otherRequirements'] = this.otherRequirements;
    data['currency'] = this.currency;
    data['applicationFee'] = this.applicationFee;
    data['status'] = this.status;
    data['minBaGpa'] = this.minBaGpa;
    return data;
  }
}

class UniversityLinks {
  double? applicationFee;
  String? currency;
  University? university;

  UniversityLinks({this.applicationFee, this.currency, this.university});

  UniversityLinks.fromJson(Map<String, dynamic> json) {
    applicationFee = _toDouble(json['applicationFee']);
    currency = json['currency'];
    final universityJson = _toStringDynamicMap(json['university']);
    university =
        universityJson != null ? University.fromJson(universityJson) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['applicationFee'] = this.applicationFee;
    data['currency'] = this.currency;
    if (this.university != null) {
      data['university'] = this.university!.toJson();
    }
    return data;
  }
}

class University {
  String? id;
  String? name;

  University({this.id, this.name});

  University.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class ProgramLinks {
  String? id;
  String? universityId;
  String? programId;
  double? applicationFee;
  double? taxes;
  String? currency;
  bool? isEnabled;
  String? createdAt;
  String? updatedAt;
  Program? program;

  ProgramLinks(
      {this.id,
      this.universityId,
      this.programId,
      this.applicationFee,
      this.taxes,
      this.currency,
      this.isEnabled,
      this.createdAt,
      this.updatedAt,
      this.program});

  ProgramLinks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    universityId = json['universityId'];
    programId = json['programId'];
    applicationFee = _toDouble(json['applicationFee']);
    taxes = _toDouble(json['taxes']);
    currency = json['currency'];
    isEnabled = json['isEnabled'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    final programJson = _toStringDynamicMap(json['program']);
    program = programJson != null ? Program.fromJson(programJson) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['universityId'] = this.universityId;
    data['programId'] = this.programId;
    data['applicationFee'] = this.applicationFee;
    data['taxes'] = this.taxes;
    data['currency'] = this.currency;
    data['isEnabled'] = this.isEnabled;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.program != null) {
      data['program'] = this.program!.toJson();
    }
    return data;
  }
}

class Ratings {
  String? id;
  String? studentId;
  String? universityId;
  double? rating;
  String? remark;
  dynamic imagePath;
  String? createdAt;
  String? updatedAt;
  Student? student;

  Ratings(
      {this.id,
      this.studentId,
      this.universityId,
      this.rating,
      this.remark,
      this.imagePath,
      this.createdAt,
      this.updatedAt,
      this.student});

  Ratings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    studentId = json['studentId'];
    universityId = json['universityId'];
    rating = _toDouble(json['rating']);
    remark = json['remark'];
    imagePath = json['imagePath'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    final studentJson = _toStringDynamicMap(json['student']);
    student = studentJson != null ? Student.fromJson(studentJson) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['studentId'] = this.studentId;
    data['universityId'] = this.universityId;
    data['rating'] = this.rating;
    data['remark'] = this.remark;
    data['imagePath'] = this.imagePath;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.student != null) {
      data['student'] = this.student!.toJson();
    }
    return data;
  }
}

class Student {
  String? firstName;
  String? lastName;

  Student({this.firstName, this.lastName});

  Student.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    return data;
  }
}

class AcademicPrograms {
  String? academicname;
  List<Colleges>? colleges;

  AcademicPrograms({this.academicname, this.colleges});

  AcademicPrograms.fromJson(Map<String, dynamic> json) {
    academicname = json['academicname'];
    final collegesJson = _toDynamicList(json['colleges']);
    if (collegesJson != null) {
      colleges = <Colleges>[];
      for (final item in collegesJson) {
        final itemJson = _toStringDynamicMap(item);
        if (itemJson != null) {
          colleges!.add(Colleges.fromJson(itemJson));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['academicname'] = this.academicname;
    if (this.colleges != null) {
      data['colleges'] = this.colleges!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Colleges {
  String? college;
  List<Courses>? courses;

  Colleges({this.college, this.courses});

  Colleges.fromJson(Map<String, dynamic> json) {
    college = json['college'];
    final coursesJson = _toDynamicList(json['courses']);
    if (coursesJson != null) {
      courses = <Courses>[];
      for (final item in coursesJson) {
        final itemJson = _toStringDynamicMap(item);
        if (itemJson != null) {
          courses!.add(Courses.fromJson(itemJson));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['college'] = this.college;
    if (this.courses != null) {
      data['courses'] = this.courses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Courses {
  String? programId;
  String? programName;
  String? academicProgram;
  String? educationInstitute;
  String? name;
  bool? isBooked;
  String? track;
  String? duration;
  double? creditHours;
  double? totalFees;
  String? semesters;
  String? totalSemesters;
  double? feePerCredit;
  double? semesterFee;
  double? annualFee;
  double? basePrice;
  double? minAdmissionRate;
  List<String>? eligibility;
  List<String>? otherRequirements;
  String? currency;
  double? applicationFee;
  String? status;
  double? commissionPercent;
  String? minBaGpa;

  Courses(
      {this.programId,
      this.programName,
      this.academicProgram,
      this.educationInstitute,
      this.name,
      this.isBooked,
      this.track,
      this.duration,
      this.creditHours,
      this.totalFees,
      this.semesters,
      this.totalSemesters,
      this.feePerCredit,
      this.semesterFee,
      this.annualFee,
      this.basePrice,
      this.minAdmissionRate,
      this.eligibility,
      this.otherRequirements,
      this.currency,
      this.applicationFee,
      this.status,
      this.commissionPercent,
      this.minBaGpa});

  factory Courses.fromCourseDetails(
    CourseDetails details, {
    Program? program,
    String? academicName,
    String? collegeName,
  }) {
    return Courses(
      programId: program?.id,
      programName: program?.name,
      academicProgram: program?.academicProgram ?? academicName,
      educationInstitute: program?.educationInstitute ?? collegeName,
      name: details.name,
      isBooked: details.isBooked,
      track: details.track ?? program?.track,
      duration: details.duration,
      creditHours: details.creditHours,
      totalFees: details.totalFees,
      semesters: details.semesters.toString(),
      totalSemesters: details.totalSemesters.toString(),
      feePerCredit: details.feePerCredit,
      semesterFee: details.semesterFee,
      annualFee: details.annualFee,
      basePrice: details.basePrice ?? program?.basePrice,
      minAdmissionRate: details.minAdmissionRate ?? program?.minAdmissionRate,
      eligibility: details.eligibility ?? program?.eligibilityTitle,
      otherRequirements:
          details.otherRequirements ?? program?.scholarshipInfoTitle,
      currency: details.currency ?? program?.currency,
      applicationFee: details.applicationFee,
      status: details.status ?? program?.status,
      commissionPercent: program?.commissionPercent,
      minBaGpa: details.minBaGpa ?? program?.minBaGpa,
    );
  }

  Courses.fromJson(Map<String, dynamic> json) {
    programId = json['programId'];
    programName = json['programName'];
    academicProgram = json['academicProgram'];
    educationInstitute = json['educationInstitute'];
    name = json['name'];
    isBooked = json['isBooked'];
    track = json['track'];
    duration = json['duration'];
    creditHours = _toDouble(json['creditHours']);
    totalFees = _toDouble(json['totalFees']);
    semesters = json['semesters'];
    totalSemesters = json['totalSemesters'];
    feePerCredit = _toDouble(json['feePerCredit']);
    semesterFee = _toDouble(json['semesterFee']);
    annualFee = _toDouble(json['annualFee']);
    basePrice = _toDouble(json['basePrice']);
    minAdmissionRate = _toDouble(json['minAdmissionRate']);
    eligibility = _toStringList(json['eligibility']);
    otherRequirements = _toStringList(json['otherRequirements']);
    currency = json['currency'];
    applicationFee = _toDouble(json['applicationFee']);
    status = json['status'];
    commissionPercent = _toDouble(json['commissionPercent']);
    minBaGpa = json['minBaGpa'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['programId'] = this.programId;
    data['programName'] = this.programName;
    data['academicProgram'] = this.academicProgram;
    data['educationInstitute'] = this.educationInstitute;
    data['name'] = this.name;
    data['isBooked'] = this.isBooked;
    data['track'] = this.track;
    data['duration'] = this.duration;
    data['creditHours'] = this.creditHours;
    data['totalFees'] = this.totalFees;
    data['semesters'] = this.semesters;
    data['totalSemesters'] = this.totalSemesters;
    data['feePerCredit'] = this.feePerCredit;
    data['semesterFee'] = this.semesterFee;
    data['annualFee'] = this.annualFee;
    data['basePrice'] = this.basePrice;
    data['minAdmissionRate'] = this.minAdmissionRate;
    data['eligibility'] = this.eligibility;
    data['otherRequirements'] = this.otherRequirements;
    data['currency'] = this.currency;
    data['applicationFee'] = this.applicationFee;
    data['status'] = this.status;
    data['commissionPercent'] = this.commissionPercent;
    data['minBaGpa'] = this.minBaGpa;
    return data;
  }
}
