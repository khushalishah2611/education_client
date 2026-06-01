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
    return StudentNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      titleAr: (json['titleAr'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      messageAr: (json['messageAr'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      isRead: json['isRead'] == true,
    );
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
