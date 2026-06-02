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

    String localizedString(
      List<String> directKeys, {
      required List<String> nestedKeys,
    }) {
      for (final key in directKeys) {
        final value = json[key];
        final directValue = safeString(value);
        if (directValue.isNotEmpty) return directValue;

        if (value is Map) {
          for (final nestedKey in nestedKeys) {
            final nestedValue = safeString(value[nestedKey]);
            if (nestedValue.isNotEmpty) return nestedValue;
          }
        }
      }
      return '';
    }

    return StudentNotification(
      id: safeString(json['id']),
      title: localizedString(
        const ['title', 'titleEn', 'titleEnglish', 'subject', 'subjectEn'],
        nestedKeys: const ['en', 'en_US', 'english', 'value'],
      ),
      titleAr: localizedString(
        const ['titleAr', 'titleArabic', 'arabicTitle', 'title', 'subjectAr'],
        nestedKeys: const ['ar', 'ar_SA', 'arabic', 'value'],
      ),
      message: localizedString(
        const ['message', 'messageEn', 'messageEnglish', 'body', 'bodyEn'],
        nestedKeys: const ['en', 'en_US', 'english', 'value'],
      ),
      messageAr: localizedString(
        const [
          'messageAr',
          'messageArabic',
          'arabicMessage',
          'bodyAr',
          'message',
        ],
        nestedKeys: const ['ar', 'ar_SA', 'arabic', 'value'],
      ),
      createdAt: safeString(json['createdAt']),
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
