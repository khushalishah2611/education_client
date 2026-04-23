class AdminUniversity {
  String? id;
  String? name;
  String? country;
  String? state;
  String? city;
  String? email;
  String? mobile;
  int? rating;
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
  List<Null>? services;
  List<Ratings>? ratings;
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
        this.services,
        this.ratings,
       });

  AdminUniversity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    country = json['country'];
    state = json['state'];
    city = json['city'];
    email = json['email'];
    mobile = json['mobile'];
    rating = json['rating'];
    if (json['academicList'] != null) {
      academicList = <AcademicList>[];
      json['academicList'].forEach((v) {
        academicList!.add(new AcademicList.fromJson(v));
      });
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
    if (json['programLinks'] != null) {
      programLinks = <ProgramLinks>[];
      json['programLinks'].forEach((v) {
        programLinks!.add(new ProgramLinks.fromJson(v));
      });
    }
    if (json['ratings'] != null) {
      ratings = <Ratings>[];
      json['ratings'].forEach((v) {
        ratings!.add(new Ratings.fromJson(v));
      });
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
    return data;
  }
}

class AcademicList {
  String? academicname;
  String? college;

  AcademicList({this.academicname, this.college});

  AcademicList.fromJson(Map<String, dynamic> json) {
    academicname = json['academicname'];
    college = json['college'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['academicname'] = this.academicname;
    data['college'] = this.college;
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
    applicationFee = json['applicationFee'];
    taxes = json['taxes'];
    currency = json['currency'];
    isEnabled = json['isEnabled'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    program =
    json['program'] != null ? new Program.fromJson(json['program']) : null;
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

class Program {
  String? id;
  String? name;
  String? academicProgram;
  String? courseNames;
  String? courseDetails;
  String? track;
  int? minAdmissionRate;
  int? requiredScore;
  int? discountedScore;
  String? status;
  bool? isEnabled;
  int? basePrice;
  String? currency;
  int? commissionPercent;
  String? coverImagePath;
  String? eligibilityTitle;
  Null? scholarshipInfoTitle;
  String? createdAt;
  String? updatedAt;
  List<Null>? intakes;
  List<UniversityLinks>? universityLinks;
  String? educationInstitute;

  Program(
      {this.id,
        this.name,
        this.academicProgram,
        this.courseNames,
        this.courseDetails,
        this.track,
        this.minAdmissionRate,
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
        this.educationInstitute});

  Program.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    academicProgram = json['academicProgram'];
    courseNames = json['courseNames'];
    courseDetails = json['courseDetails'];
    track = json['track'];
    minAdmissionRate = json['minAdmissionRate'];
    requiredScore = json['requiredScore'];
    discountedScore = json['discountedScore'];
    status = json['status'];
    isEnabled = json['isEnabled'];
    basePrice = json['basePrice'];
    currency = json['currency'];
    commissionPercent = json['commissionPercent'];
    coverImagePath = json['coverImagePath'];
    eligibilityTitle = json['eligibilityTitle'];
    scholarshipInfoTitle = json['scholarshipInfoTitle'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['universityLinks'] != null) {
      universityLinks = <UniversityLinks>[];
      json['universityLinks'].forEach((v) {
        universityLinks!.add(new UniversityLinks.fromJson(v));
      });
    }
    educationInstitute = json['educationInstitute'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['academicProgram'] = this.academicProgram;
    data['courseNames'] = this.courseNames;
    data['courseDetails'] = this.courseDetails;
    data['track'] = this.track;
    data['minAdmissionRate'] = this.minAdmissionRate;
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
    return data;
  }
}

class UniversityLinks {
  int? applicationFee;
  String? currency;
  University? university;

  UniversityLinks({this.applicationFee, this.currency, this.university});

  UniversityLinks.fromJson(Map<String, dynamic> json) {
    applicationFee = json['applicationFee'];
    currency = json['currency'];
    university = json['university'] != null
        ? new University.fromJson(json['university'])
        : null;
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

class Ratings {
  String? id;
  String? studentId;
  String? universityId;
  int? rating;
  String? remark;
  Null? imagePath;
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
    rating = json['rating'];
    remark = json['remark'];
    imagePath = json['imagePath'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    student =
    json['student'] != null ? new Student.fromJson(json['student']) : null;
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

class ProgramData {
  String? id;
  String? name;
  String? academicProgram;
  String? courseNames;
  List<CourseDetails>? courseDetails;
  String? track;
  Null? description;
  Null? durationMonths;
  int? minAdmissionRate;
  int? requiredScore;
  int? discountedScore;
  String? status;
  bool? isEnabled;
  int? basePrice;
  String? currency;
  int? commissionPercent;
  String? coverImagePath;
  List<String>? eligibilityTitle;
  List<Null>? scholarshipInfoTitle;
  String? createdAt;
  String? updatedAt;
  List<Null>? intakes;
  List<UniversityLinks>? universityLinks;
  String? educationInstitute;
  List<String>? courses;

  ProgramData(
      {this.id,
        this.name,
        this.academicProgram,
        this.courseNames,
        this.courseDetails,
        this.track,
        this.description,
        this.durationMonths,
        this.minAdmissionRate,
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
        this.courses});

  ProgramData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    academicProgram = json['academicProgram'];
    courseNames = json['courseNames'];
    if (json['courseDetails'] != null) {
      courseDetails = <CourseDetails>[];
      json['courseDetails'].forEach((v) {
        courseDetails!.add(new CourseDetails.fromJson(v));
      });
    }
    track = json['track'];
    description = json['description'];
    durationMonths = json['durationMonths'];
    minAdmissionRate = json['minAdmissionRate'];
    requiredScore = json['requiredScore'];
    discountedScore = json['discountedScore'];
    status = json['status'];
    isEnabled = json['isEnabled'];
    basePrice = json['basePrice'];
    currency = json['currency'];
    commissionPercent = json['commissionPercent'];
    coverImagePath = json['coverImagePath'];
    eligibilityTitle = json['eligibilityTitle'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['universityLinks'] != null) {
      universityLinks = <UniversityLinks>[];
      json['universityLinks'].forEach((v) {
        universityLinks!.add(new UniversityLinks.fromJson(v));
      });
    }
    educationInstitute = json['educationInstitute'];
    courses = json['courses'].cast<String>();
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
    data['requiredScore'] = this.requiredScore;
    data['discountedScore'] = this.discountedScore;
    data['status'] = this.status;
    data['isEnabled'] = this.isEnabled;
    data['basePrice'] = this.basePrice;
    data['currency'] = this.currency;
    data['commissionPercent'] = this.commissionPercent;
    data['coverImagePath'] = this.coverImagePath;
    data['eligibilityTitle'] = this.eligibilityTitle;
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
  int? creditHours;
  int? totalFees;
  int? semesters;
  int? feePerCredit;
  int? semesterFee;
  int? annualFee;
  int? basePrice;
  int? minAdmissionRate;
  int? requiredScore;
  int? discountedScore;
  List<String>? eligibility;
  List<String>? otherRequirements;
  String? currency;
  int? applicationFee;
  String? coverImagePath;
  String? status;

  CourseDetails(
      {this.name,
        this.isBooked,
        this.track,
        this.duration,
        this.creditHours,
        this.totalFees,
        this.semesters,
        this.feePerCredit,
        this.semesterFee,
        this.annualFee,
        this.basePrice,
        this.minAdmissionRate,
        this.requiredScore,
        this.discountedScore,
        this.eligibility,
        this.otherRequirements,
        this.currency,
        this.applicationFee,
        this.coverImagePath,
        this.status});

  CourseDetails.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    isBooked = json['isBooked'];
    track = json['track'];
    duration = json['duration'];
    creditHours = json['creditHours'];
    totalFees = json['totalFees'];
    semesters = json['semesters'];
    feePerCredit = json['feePerCredit'];
    semesterFee = json['semesterFee'];
    annualFee = json['annualFee'];
    basePrice = json['basePrice'];
    minAdmissionRate = json['minAdmissionRate'];
    requiredScore = json['requiredScore'];
    discountedScore = json['discountedScore'];
    eligibility = json['eligibility'].cast<String>();
    otherRequirements = json['otherRequirements'].cast<String>();
    currency = json['currency'];
    applicationFee = json['applicationFee'];
    coverImagePath = json['coverImagePath'];
    status = json['status'];
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
    data['feePerCredit'] = this.feePerCredit;
    data['semesterFee'] = this.semesterFee;
    data['annualFee'] = this.annualFee;
    data['basePrice'] = this.basePrice;
    data['minAdmissionRate'] = this.minAdmissionRate;
    data['requiredScore'] = this.requiredScore;
    data['discountedScore'] = this.discountedScore;
    data['eligibility'] = this.eligibility;
    data['otherRequirements'] = this.otherRequirements;
    data['currency'] = this.currency;
    data['applicationFee'] = this.applicationFee;
    data['coverImagePath'] = this.coverImagePath;
    data['status'] = this.status;
    return data;
  }
}
