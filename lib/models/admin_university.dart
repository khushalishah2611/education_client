import 'dart:convert';

class AdminUniversity {
  String? id;
  String? name;
  String? academicProgram;
  String? courseNames;
  String? track;
  String? country;
  String? state;
  String? city;
  String? email;
  String? mobile;
  String? institute;
  int? rating;
  List<AcademicList>? academicList;
  int? cutoffPercentage;
  String? logoPath;
  String? coverImagePath;
  String? address;
  String? aboutUs;
  bool? accredited;
  String? status;
  bool? isEnabled;
  String? contractStart;
  String? contractEnd;
  String? createdAt;
  String? updatedAt;
  List<dynamic>? services;
  List<ProgramLinks>? programLinks;
  List<Ratings>? ratings;
  double? averageRating;
  int? ratingCount;

  AdminUniversity({
    this.id,
    this.name,
    this.academicProgram,
    this.courseNames,
    this.track,
    this.country,
    this.state,
    this.city,
    this.email,
    this.mobile,
    this.institute,
    this.rating,
    this.academicList,
    this.cutoffPercentage,
    this.logoPath,
    this.coverImagePath,
    this.address,
    this.aboutUs,
    this.accredited,
    this.status,
    this.isEnabled,
    this.contractStart,
    this.contractEnd,
    this.createdAt,
    this.updatedAt,
    this.services,
    this.programLinks,
    this.ratings,
    this.averageRating,
    this.ratingCount,
  });

  AdminUniversity.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    academicProgram = json['academicProgram']?.toString();
    courseNames = json['courseNames']?.toString();
    track = json['track']?.toString();
    country = json['country']?.toString();
    state = json['state']?.toString();
    city = json['city']?.toString();
    email = json['email']?.toString();
    mobile = json['mobile']?.toString();
    institute = json['institute']?.toString();
    rating = _asInt(json['rating']);
    academicList = _parseAcademicList(json['academicList']);
    cutoffPercentage = _asInt(json['cutoffPercentage']);
    logoPath = json['logoPath']?.toString();
    coverImagePath = json['coverImagePath']?.toString();
    address = json['address']?.toString();
    aboutUs = json['aboutUs']?.toString();
    accredited = json['accredited'] as bool?;
    status = json['status']?.toString();
    isEnabled = json['isEnabled'] as bool?;
    contractStart = json['contractStart']?.toString();
    contractEnd = json['contractEnd']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    if (json['services'] is List) {
      services = List<dynamic>.from(json['services'] as List);
    }
    if (json['programLinks'] is List) {
      programLinks = (json['programLinks'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ProgramLinks.fromJson)
          .toList();
    }
    if (json['ratings'] is List) {
      ratings = (json['ratings'] as List)
          .whereType<Map<String, dynamic>>()
          .map(Ratings.fromJson)
          .toList();
    }
    averageRating = _asDouble(json['averageRating']);
    ratingCount = _asInt(json['ratingCount']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    _addIfNotNull(data, 'id', id);
    _addIfNotNull(data, 'name', name);
    _addIfNotNull(data, 'academicProgram', academicProgram);
    _addIfNotNull(data, 'courseNames', courseNames);
    _addIfNotNull(data, 'track', track);
    _addIfNotNull(data, 'country', country);
    _addIfNotNull(data, 'state', state);
    _addIfNotNull(data, 'city', city);
    _addIfNotNull(data, 'email', email);
    _addIfNotNull(data, 'mobile', mobile);
    _addIfNotNull(data, 'institute', institute);
    _addIfNotNull(data, 'rating', rating);
    if (academicList != null) {
      data['academicList'] = academicList!.map((v) => v.toJson()).toList();
    }
    _addIfNotNull(data, 'cutoffPercentage', cutoffPercentage);
    _addIfNotNull(data, 'logoPath', logoPath);
    _addIfNotNull(data, 'coverImagePath', coverImagePath);
    _addIfNotNull(data, 'address', address);
    _addIfNotNull(data, 'aboutUs', aboutUs);
    _addIfNotNull(data, 'accredited', accredited);
    _addIfNotNull(data, 'status', status);
    _addIfNotNull(data, 'isEnabled', isEnabled);
    _addIfNotNull(data, 'contractStart', contractStart);
    _addIfNotNull(data, 'contractEnd', contractEnd);
    _addIfNotNull(data, 'createdAt', createdAt);
    _addIfNotNull(data, 'updatedAt', updatedAt);
    _addIfNotNull(data, 'services', services);
    if (programLinks != null) {
      data['programLinks'] = programLinks!.map((v) => v.toJson()).toList();
    }
    if (ratings != null) {
      data['ratings'] = ratings!.map((v) => v.toJson()).toList();
    }
    _addIfNotNull(data, 'averageRating', averageRating);
    _addIfNotNull(data, 'ratingCount', ratingCount);
    return data;
  }
}

class AcademicList {
  String? academicname;
  String? college;
  ProgramData? program;
  List<AcademicCollege>? colleges;

  AcademicList({this.academicname, this.college, this.program, this.colleges});

  AcademicList.fromJson(Map<String, dynamic> json) {
    academicname = json['academicname']?.toString();
    college = json['college']?.toString();
    if (json['program'] is Map<String, dynamic>) {
      program = ProgramData.fromJson(json['program'] as Map<String, dynamic>);
    }
    if (json['colleges'] is List) {
      colleges = (json['colleges'] as List)
          .whereType<Map<String, dynamic>>()
          .map(AcademicCollege.fromJson)
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    _addIfNotNull(data, 'academicname', academicname);
    _addIfNotNull(data, 'college', college);
    if (program != null) {
      data['program'] = program!.toJson();
    }
    if (colleges != null) {
      data['colleges'] = colleges!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AcademicCollege {
  String? college;
  List<CourseDetails>? courses;

  AcademicCollege({this.college, this.courses});

  AcademicCollege.fromJson(Map<String, dynamic> json) {
    college = json['college']?.toString();
    courses = _parseCourseDetails(json['courses']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    _addIfNotNull(data, 'college', college);
    if (courses != null) {
      data['courses'] = courses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProgramLinks {
  String? id;
  String? universityId;
  String? programId;
  int? applicationFee;
  int? taxes;
  String? currency;
  bool? isEnabled;
  String? createdAt;
  String? updatedAt;
  Program? program;

  ProgramLinks({
    this.id,
    this.universityId,
    this.programId,
    this.applicationFee,
    this.taxes,
    this.currency,
    this.isEnabled,
    this.createdAt,
    this.updatedAt,
    this.program,
  });

  ProgramLinks.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    universityId = json['universityId']?.toString();
    programId = json['programId']?.toString();
    applicationFee = _asInt(json['applicationFee']);
    taxes = _asInt(json['taxes']);
    currency = json['currency']?.toString();
    isEnabled = json['isEnabled'] as bool?;
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    if (json['program'] is Map<String, dynamic>) {
      program = Program.fromJson(json['program'] as Map<String, dynamic>);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    _addIfNotNull(data, 'id', id);
    _addIfNotNull(data, 'universityId', universityId);
    _addIfNotNull(data, 'programId', programId);
    _addIfNotNull(data, 'applicationFee', applicationFee);
    _addIfNotNull(data, 'taxes', taxes);
    _addIfNotNull(data, 'currency', currency);
    _addIfNotNull(data, 'isEnabled', isEnabled);
    _addIfNotNull(data, 'createdAt', createdAt);
    _addIfNotNull(data, 'updatedAt', updatedAt);
    if (program != null) {
      data['program'] = program!.toJson();
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
  int? minAdmissionRate;
  String? minBaGpa;
  int? requiredScore;
  int? discountedScore;
  String? status;
  bool? isEnabled;
  int? basePrice;
  String? currency;
  int? commissionPercent;
  String? coverImagePath;
  List<String>? eligibilityTitle;
  List<dynamic>? scholarshipInfoTitle;
  String? createdAt;
  String? updatedAt;
  List<dynamic>? intakes;
  List<UniversityLinks>? universityLinks;
  String? educationInstitute;
  List<String>? courses;

  Program({
    this.id,
    this.name,
    this.academicProgram,
    this.courseNames,
    this.courseDetails,
    this.track,
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
    this.intakes,
    this.universityLinks,
    this.educationInstitute,
    this.courses,
  });

  Program.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    academicProgram = json['academicProgram']?.toString();
    courseNames = json['courseNames']?.toString();
    courseDetails = _parseCourseDetails(json['courseDetails']);
    track = json['track']?.toString();
    minAdmissionRate = _asInt(json['minAdmissionRate']);
    minBaGpa = json['minBaGpa']?.toString();
    requiredScore = _asInt(json['requiredScore']);
    discountedScore = _asInt(json['discountedScore']);
    status = json['status']?.toString();
    isEnabled = json['isEnabled'] as bool?;
    basePrice = _asInt(json['basePrice']);
    currency = json['currency']?.toString();
    commissionPercent = _asInt(json['commissionPercent']);
    coverImagePath = json['coverImagePath']?.toString();
    eligibilityTitle = _toStringList(json['eligibilityTitle']);
    scholarshipInfoTitle = _toDynamicList(json['scholarshipInfoTitle']);
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    intakes = _toDynamicList(json['intakes']);
    if (json['universityLinks'] is List) {
      universityLinks = (json['universityLinks'] as List)
          .whereType<Map<String, dynamic>>()
          .map(UniversityLinks.fromJson)
          .toList();
    }
    educationInstitute = json['educationInstitute']?.toString();
    courses = _toStringList(json['courses']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    _addIfNotNull(data, 'id', id);
    _addIfNotNull(data, 'name', name);
    _addIfNotNull(data, 'academicProgram', academicProgram);
    _addIfNotNull(data, 'courseNames', courseNames);
    if (courseDetails != null) {
      data['courseDetails'] = courseDetails!.map((v) => v.toJson()).toList();
    }
    _addIfNotNull(data, 'track', track);
    _addIfNotNull(data, 'minAdmissionRate', minAdmissionRate);
    _addIfNotNull(data, 'minBaGpa', minBaGpa);
    _addIfNotNull(data, 'requiredScore', requiredScore);
    _addIfNotNull(data, 'discountedScore', discountedScore);
    _addIfNotNull(data, 'status', status);
    _addIfNotNull(data, 'isEnabled', isEnabled);
    _addIfNotNull(data, 'basePrice', basePrice);
    _addIfNotNull(data, 'currency', currency);
    _addIfNotNull(data, 'commissionPercent', commissionPercent);
    _addIfNotNull(data, 'coverImagePath', coverImagePath);
    _addIfNotNull(data, 'eligibilityTitle', eligibilityTitle);
    _addIfNotNull(data, 'scholarshipInfoTitle', scholarshipInfoTitle);
    _addIfNotNull(data, 'createdAt', createdAt);
    _addIfNotNull(data, 'updatedAt', updatedAt);
    _addIfNotNull(data, 'intakes', intakes);
    if (universityLinks != null) {
      data['universityLinks'] = universityLinks!
          .map((v) => v.toJson())
          .toList();
    }
    _addIfNotNull(data, 'educationInstitute', educationInstitute);
    _addIfNotNull(data, 'courses', courses);
    return data;
  }
}

class UniversityLinks {
  int? applicationFee;
  String? currency;
  University? university;

  UniversityLinks({this.applicationFee, this.currency, this.university});

  UniversityLinks.fromJson(Map<String, dynamic> json) {
    applicationFee = _asInt(json['applicationFee']);
    currency = json['currency']?.toString();
    if (json['university'] is Map<String, dynamic>) {
      university = University.fromJson(
        json['university'] as Map<String, dynamic>,
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    _addIfNotNull(data, 'applicationFee', applicationFee);
    _addIfNotNull(data, 'currency', currency);
    if (university != null) {
      data['university'] = university!.toJson();
    }
    return data;
  }
}

class University {
  String? id;
  String? name;

  University({this.id, this.name});

  University.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    _addIfNotNull(data, 'id', id);
    _addIfNotNull(data, 'name', name);
    return data;
  }
}

class Ratings {
  String? id;
  String? studentId;
  String? universityId;
  int? rating;
  String? remark;
  String? imagePath;
  String? createdAt;
  String? updatedAt;
  Student? student;

  Ratings({
    this.id,
    this.studentId,
    this.universityId,
    this.rating,
    this.remark,
    this.imagePath,
    this.createdAt,
    this.updatedAt,
    this.student,
  });

  Ratings.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    studentId = json['studentId']?.toString();
    universityId = json['universityId']?.toString();
    rating = _asInt(json['rating']);
    remark = json['remark']?.toString();
    imagePath = json['imagePath']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    if (json['student'] is Map<String, dynamic>) {
      student = Student.fromJson(json['student'] as Map<String, dynamic>);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    _addIfNotNull(data, 'id', id);
    _addIfNotNull(data, 'studentId', studentId);
    _addIfNotNull(data, 'universityId', universityId);
    _addIfNotNull(data, 'rating', rating);
    _addIfNotNull(data, 'remark', remark);
    _addIfNotNull(data, 'imagePath', imagePath);
    _addIfNotNull(data, 'createdAt', createdAt);
    _addIfNotNull(data, 'updatedAt', updatedAt);
    if (student != null) {
      data['student'] = student!.toJson();
    }
    return data;
  }
}

class Student {
  String? firstName;
  String? lastName;

  Student({this.firstName, this.lastName});

  Student.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName']?.toString();
    lastName = json['lastName']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    _addIfNotNull(data, 'firstName', firstName);
    _addIfNotNull(data, 'lastName', lastName);
    return data;
  }
}

class ProgramData {
  String? id;
  String? name;
  String? academicProgram;
  String? courseNames;
  List<CourseDetails>? courseDetails;
  String? track;
  dynamic description;
  dynamic durationMonths;
  int? minAdmissionRate;
  String? minBaGpa;
  int? requiredScore;
  int? discountedScore;
  String? status;
  bool? isEnabled;
  int? basePrice;
  String? currency;
  int? commissionPercent;
  String? coverImagePath;
  List<String>? eligibilityTitle;
  List<dynamic>? scholarshipInfoTitle;
  String? createdAt;
  String? updatedAt;
  List<dynamic>? intakes;
  List<UniversityLinks>? universityLinks;
  String? educationInstitute;
  List<String>? courses;

  ProgramData({
    this.id,
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
    this.intakes,
    this.universityLinks,
    this.educationInstitute,
    this.courses,
  });

  ProgramData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    academicProgram = json['academicProgram']?.toString();
    courseNames = json['courseNames']?.toString();
    courseDetails = _parseCourseDetails(json['courseDetails']);
    track = json['track']?.toString();
    description = json['description'];
    durationMonths = json['durationMonths'];
    minAdmissionRate = _asInt(json['minAdmissionRate']);
    minBaGpa = json['minBaGpa']?.toString();
    requiredScore = _asInt(json['requiredScore']);
    discountedScore = _asInt(json['discountedScore']);
    status = json['status']?.toString();
    isEnabled = json['isEnabled'] as bool?;
    basePrice = _asInt(json['basePrice']);
    currency = json['currency']?.toString();
    commissionPercent = _asInt(json['commissionPercent']);
    coverImagePath = json['coverImagePath']?.toString();
    eligibilityTitle = _toStringList(json['eligibilityTitle']);
    scholarshipInfoTitle = _toDynamicList(json['scholarshipInfoTitle']);
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    intakes = _toDynamicList(json['intakes']);
    if (json['universityLinks'] is List) {
      universityLinks = (json['universityLinks'] as List)
          .whereType<Map<String, dynamic>>()
          .map(UniversityLinks.fromJson)
          .toList();
    }
    educationInstitute = json['educationInstitute']?.toString();
    courses = _toStringList(json['courses']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    _addIfNotNull(data, 'id', id);
    _addIfNotNull(data, 'name', name);
    _addIfNotNull(data, 'academicProgram', academicProgram);
    _addIfNotNull(data, 'courseNames', courseNames);
    if (courseDetails != null) {
      data['courseDetails'] = courseDetails!.map((v) => v.toJson()).toList();
    }
    _addIfNotNull(data, 'track', track);
    _addIfNotNull(data, 'description', description);
    _addIfNotNull(data, 'durationMonths', durationMonths);
    _addIfNotNull(data, 'minAdmissionRate', minAdmissionRate);
    _addIfNotNull(data, 'minBaGpa', minBaGpa);
    _addIfNotNull(data, 'requiredScore', requiredScore);
    _addIfNotNull(data, 'discountedScore', discountedScore);
    _addIfNotNull(data, 'status', status);
    _addIfNotNull(data, 'isEnabled', isEnabled);
    _addIfNotNull(data, 'basePrice', basePrice);
    _addIfNotNull(data, 'currency', currency);
    _addIfNotNull(data, 'commissionPercent', commissionPercent);
    _addIfNotNull(data, 'coverImagePath', coverImagePath);
    _addIfNotNull(data, 'eligibilityTitle', eligibilityTitle);
    _addIfNotNull(data, 'scholarshipInfoTitle', scholarshipInfoTitle);
    _addIfNotNull(data, 'createdAt', createdAt);
    _addIfNotNull(data, 'updatedAt', updatedAt);
    _addIfNotNull(data, 'intakes', intakes);
    if (universityLinks != null) {
      data['universityLinks'] = universityLinks!
          .map((v) => v.toJson())
          .toList();
    }
    _addIfNotNull(data, 'educationInstitute', educationInstitute);
    _addIfNotNull(data, 'courses', courses);
    return data;
  }
}

class CourseDetails {
  String? programId;
  String? programName;
  String? academicProgram;
  String? educationInstitute;
  String? name;
  bool? isBooked;
  String? track;
  String? duration;
  int? creditHours;
  int? totalFees;
  int? semesters;
  int? totalSemesters;
  int? feePerCredit;
  int? semesterFee;
  int? annualFee;
  int? basePrice;
  int? minAdmissionRate;
  String? minBaGpa;
  int? requiredScore;
  int? discountedScore;
  List<String>? eligibility;
  List<String>? otherRequirements;
  String? currency;
  int? applicationFee;
  String? coverImagePath;
  String? status;
  int? commissionPercent;
  List<dynamic>? intakes;

  CourseDetails({
    this.programId,
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
    this.minBaGpa,
    this.requiredScore,
    this.discountedScore,
    this.eligibility,
    this.otherRequirements,
    this.currency,
    this.applicationFee,
    this.coverImagePath,
    this.status,
    this.commissionPercent,
    this.intakes,
  });

  CourseDetails.fromJson(Map<String, dynamic> json) {
    programId = json['programId']?.toString();
    programName = json['programName']?.toString();
    academicProgram = json['academicProgram']?.toString();
    educationInstitute = json['educationInstitute']?.toString();
    name = json['name']?.toString();
    isBooked = _asBool(json['isBooked']);
    track = json['track']?.toString();
    duration = json['duration']?.toString();
    creditHours = _asInt(json['creditHours']);
    totalFees = _asInt(json['totalFees']);
    semesters = _asInt(json['semesters']);
    totalSemesters = _asInt(json['totalSemesters']);
    feePerCredit = _asInt(json['feePerCredit']);
    semesterFee = _asInt(json['semesterFee']);
    annualFee = _asInt(json['annualFee']);
    basePrice = _asInt(json['basePrice']);
    minAdmissionRate = _asInt(json['minAdmissionRate']);
    minBaGpa = json['minBaGpa']?.toString();
    requiredScore = _asInt(json['requiredScore']);
    discountedScore = _asInt(json['discountedScore']);
    eligibility = _toStringList(json['eligibility']);
    otherRequirements = _toStringList(json['otherRequirements']);
    currency = json['currency']?.toString();
    applicationFee = _asInt(json['applicationFee']);
    coverImagePath = json['coverImagePath']?.toString();
    status = json['status']?.toString();
    commissionPercent = _asInt(json['commissionPercent']);
    intakes = _toDynamicList(json['intakes']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    _addIfNotNull(data, 'programId', programId);
    _addIfNotNull(data, 'programName', programName);
    _addIfNotNull(data, 'academicProgram', academicProgram);
    _addIfNotNull(data, 'educationInstitute', educationInstitute);
    _addIfNotNull(data, 'name', name);
    _addIfNotNull(data, 'isBooked', isBooked);
    _addIfNotNull(data, 'track', track);
    _addIfNotNull(data, 'duration', duration);
    _addIfNotNull(data, 'creditHours', creditHours);
    _addIfNotNull(data, 'totalFees', totalFees);
    _addIfNotNull(data, 'semesters', semesters);
    _addIfNotNull(data, 'totalSemesters', totalSemesters);
    _addIfNotNull(data, 'feePerCredit', feePerCredit);
    _addIfNotNull(data, 'semesterFee', semesterFee);
    _addIfNotNull(data, 'annualFee', annualFee);
    _addIfNotNull(data, 'basePrice', basePrice);
    _addIfNotNull(data, 'minAdmissionRate', minAdmissionRate);
    _addIfNotNull(data, 'minBaGpa', minBaGpa);
    _addIfNotNull(data, 'requiredScore', requiredScore);
    _addIfNotNull(data, 'discountedScore', discountedScore);
    _addIfNotNull(data, 'eligibility', eligibility);
    _addIfNotNull(data, 'otherRequirements', otherRequirements);
    _addIfNotNull(data, 'currency', currency);
    _addIfNotNull(data, 'applicationFee', applicationFee);
    _addIfNotNull(data, 'coverImagePath', coverImagePath);
    _addIfNotNull(data, 'status', status);
    _addIfNotNull(data, 'commissionPercent', commissionPercent);
    _addIfNotNull(data, 'intakes', intakes);
    return data;
  }
}

List<AcademicList>? _parseAcademicList(dynamic value) {
  if (value == null) return null;
  if (value is! List) return null;

  final entries = <AcademicList>[];
  for (final item in value.whereType<Map<String, dynamic>>()) {
    final academicEntry = AcademicList.fromJson(item);
    final groupedColleges = academicEntry.colleges;

    if (groupedColleges == null || groupedColleges.isEmpty) {
      entries.add(academicEntry);
      continue;
    }

    for (final college in groupedColleges) {
      final courseDetails = college.courses ?? <CourseDetails>[];
      entries.add(
        AcademicList(
          academicname: academicEntry.academicname,
          college: college.college,
          program: ProgramData(
            name: academicEntry.academicname,
            academicProgram: academicEntry.academicname,
            courseNames: courseDetails
                .map((course) => course.name)
                .whereType<String>()
                .join('\n'),
            courseDetails: courseDetails,
            track: _firstNonEmpty(courseDetails.map((course) => course.track)),
            minAdmissionRate: _minimumInt(
              courseDetails.map((course) => course.minAdmissionRate),
            ),
            minBaGpa: _firstNonEmpty(
              courseDetails.map((course) => course.minBaGpa),
            ),
            status: _firstNonEmpty(
              courseDetails.map((course) => course.status),
            ),
            basePrice: _minimumInt(
              courseDetails.map((course) => course.basePrice),
            ),
            currency: _firstNonEmpty(
              courseDetails.map((course) => course.currency),
            ),
            commissionPercent: _firstInt(
              courseDetails.map((course) => course.commissionPercent),
            ),
            intakes: courseDetails
                .expand((course) => course.intakes ?? const <dynamic>[])
                .toList(),
            educationInstitute: _firstNonEmpty(
              courseDetails.map((course) => course.educationInstitute),
            ) ??
                college.college,
            courses: courseDetails
                .map((course) => course.name)
                .whereType<String>()
                .toList(),
          ),
          colleges: <AcademicCollege>[college],
        ),
      );
    }
  }

  return entries;
}

void _addIfNotNull(Map<String, dynamic> map, String key, dynamic value) {
  if (value != null) {
    map[key] = value;
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

String? _firstNonEmpty(Iterable<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
}

int? _firstInt(Iterable<int?> values) {
  for (final value in values) {
    if (value != null) return value;
  }
  return null;
}

int? _minimumInt(Iterable<int?> values) {
  int? minimum;
  for (final value in values) {
    if (value == null) continue;
    minimum = minimum == null || value < minimum ? value : minimum;
  }
  return minimum;
}

List<String>? _toStringList(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return <String>[];
    return <String>[trimmed];
  }
  return null;
}

List<dynamic>? _toDynamicList(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return List<dynamic>.from(value);
  }
  return null;
}

List<CourseDetails>? _parseCourseDetails(dynamic value) {
  if (value == null) return null;

  final list = <dynamic>[];
  if (value is List) {
    list.addAll(value);
  } else if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        list.addAll(decoded);
      }
    } catch (_) {
      // Ignore invalid JSON payloads.
    }
  }

  if (list.isEmpty) {
    return <CourseDetails>[];
  }

  return list
      .whereType<Map<String, dynamic>>()
      .map(CourseDetails.fromJson)
      .toList();
}
