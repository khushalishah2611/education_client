import '../core/app_localizations.dart';

class StudentNotification {
  const StudentNotification({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.message,
    required this.messageAr,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String titleAr;
  final String message;
  final String messageAr;
  final String createdAt;
  final bool isRead;

  factory StudentNotification.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic value) {
      if (value == null) return '';
      if (value is Map) return '';
      final str = value.toString().trim();
      return str == 'null' ? '' : str;
    }

    return StudentNotification(
      id: safeString(json['id']),
      title: safeString(json['title'] ?? json['titleEn'] ?? json['subject'] ?? ''),
      titleAr: safeString(json['titleAr'] ?? json['title_ar'] ?? json['titleArabic'] ?? ''),
      message: safeString(json['message'] ?? json['messageEn'] ?? json['body'] ?? ''),
      messageAr: safeString(json['messageAr'] ?? json['message_ar'] ?? json['messageArabic'] ?? ''),
      createdAt: _ensureValidDateTime(safeString(json['createdAt'])),
      isRead: json['isRead'] == true,
    );
  }

  static String _ensureValidDateTime(String dateStr) {
    if (dateStr.isEmpty) {
      return DateTime.now().toIso8601String();
    }
    try {
      DateTime.parse(dateStr);
      return dateStr;
    } catch (_) {
      return DateTime.now().toIso8601String();
    }
  }

  StudentNotification copyWith({bool? isRead}) {
    return StudentNotification(
      id: id,
      title: title,
      titleAr: titleAr,
      message: message,
      messageAr: messageAr,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  String localizedTitle(AppLocalizations l10n) {
    return _localizedValue(
      isArabic: l10n.isArabic,
      englishValue: title,
      arabicValue: titleAr,
      fallback: '-',
    );
  }

  String localizedMessage(AppLocalizations l10n) {
    return _localizedValue(
      isArabic: l10n.isArabic,
      englishValue: message,
      arabicValue: messageAr,
    );
  }

  static String _localizedValue({
    required bool isArabic,
    required String englishValue,
    required String arabicValue,
    String fallback = '',
  }) {
    final english = englishValue.trim();
    final arabic = arabicValue.trim();

    if (isArabic) {
      if (arabic.isNotEmpty) return arabic;
      if (english.isNotEmpty) return english;
    } else {
      if (english.isNotEmpty) return english;
      if (arabic.isNotEmpty) return arabic;
    }

    return fallback;
  }
}
