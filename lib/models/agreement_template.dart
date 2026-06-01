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
    final language = (json['language'] ?? 'en').toString().toLowerCase();

    String titleEn = '';
    String titleAr = '';
    String contentEn = '';
    String contentAr = '';

    // New API format
    if (json.containsKey('title')) {
      if (language == 'ar') {
        titleAr = (json['title'] ?? '').toString();
      } else {
        titleEn = (json['title'] ?? '').toString();
      }
    }

    if (json.containsKey('content')) {
      if (language == 'ar') {
        contentAr = (json['content'] ?? '').toString();
      } else {
        contentEn = (json['content'] ?? '').toString();
      }
    }

    // Old API format support
    titleEn = titleEn.isNotEmpty
        ? titleEn
        : (json['titleEn'] ?? '').toString();

    titleAr = titleAr.isNotEmpty
        ? titleAr
        : (json['titleAr'] ?? '').toString();

    contentEn = contentEn.isNotEmpty
        ? contentEn
        : (json['contentEn'] ?? '').toString();

    contentAr = contentAr.isNotEmpty
        ? contentAr
        : (json['contentAr'] ?? '').toString();

    return AgreementTemplate(
      id: (json['id'] ?? '').toString(),
      language: language,
      titleEn: titleEn,
      titleAr: titleAr,
      contentEn: contentEn,
      contentAr: contentAr,
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
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