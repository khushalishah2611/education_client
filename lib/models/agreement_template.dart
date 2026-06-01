class AgreementTemplate {
  final String id;
  final String language;
  final String titleEn;
  final String titleAr;
  final String contentEn;
  final String contentAr;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final bool isAccepted;

  AgreementTemplate({
    required this.id,
    required this.language,
    required this.titleEn,
    required this.titleAr,
    required this.contentEn,
    required this.contentAr,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.isAccepted,
  });

  factory AgreementTemplate.fromJson(Map<String, dynamic> json) {
    return AgreementTemplate(
      id: json['id'] ?? '',
      language: json['language'] ?? '',
      titleEn: json['titleEn'] ?? '',
      titleAr: json['titleAr'] ?? '',
      contentEn: json['contentEn'] ?? '',
      contentAr: json['contentAr'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isAccepted: json['isAccepted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'titleEn': titleEn,
      'titleAr': titleAr,
      'contentEn': contentEn,
      'contentAr': contentAr,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isAccepted': isAccepted,
    };
  }
}