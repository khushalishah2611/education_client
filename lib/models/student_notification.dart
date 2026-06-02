import 'dart:convert';

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
      id: _safeString(json['id'] ?? json['_id']),
      title: _firstNonEmpty(<String>[
        _safeString(json['title']),
        _safeString(json['titleEn']),
        _safeString(json['title_en']),
        _safeString(json['subject']),
      ]),
      titleAr: _firstNonEmpty(<String>[
        _safeString(json['titleAr']),
        _safeString(json['title_ar']),
        _safeString(json['titleArabic']),
      ]),
      message: _firstNonEmpty(<String>[
        _safeString(json['message']),
        _safeString(json['messageEn']),
        _safeString(json['message_en']),
        _safeString(json['body']),
        _safeString(json['description']),
      ]),
      messageAr: _firstNonEmpty(<String>[
        _safeString(json['messageAr']),
        _safeString(json['message_ar']),
        _safeString(json['messageArabic']),
        _safeString(json['bodyAr']),
        _safeString(json['descriptionAr']),
      ]),
      createdAt: _ensureValidDateTime(
        _firstNonEmpty(<String>[
          _safeString(json['createdAt']),
          _safeString(json['created_at']),
          _safeString(json['date']),
        ]),
      ),
      isRead: _readBool(json['isRead'] ?? json['is_read'] ?? json['read']),
    );
  }

  static List<StudentNotification> listFromResponse(Object? response) {
    final List<dynamic> rawItems = _readNotificationList(response);
    return rawItems
        .whereType<Map>()
        .map((item) => StudentNotification.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList(growable: false);
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

String _safeString(Object? value) {
  if (value == null || value is Map || value is List) return '';
  final String str = value.toString().trim();
  return str == 'null' ? '' : str;
}

String _firstNonEmpty(List<String> values) {
  for (final String value in values) {
    final String normalized = value.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }
  }
  return '';
}

bool _readBool(Object? value) {
  if (value is bool) return value;
  final String normalized = _safeString(value).toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}

List<dynamic> _readNotificationList(Object? response) {
  if (response is String) {
    try {
      return _readNotificationList(jsonDecode(response));
    } catch (_) {
      return const <dynamic>[];
    }
  }
  if (response is List<dynamic>) {
    return response;
  }
  if (response is Map) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(response);
    if (map.containsKey('notifications')) {
      return _readNotificationList(map['notifications']);
    }
    for (final String key in const <String>[
      'items',
      'data',
      'results',
    ]) {
      if (!map.containsKey(key)) {
        continue;
      }
      final List<dynamic> nested = _readNotificationList(map[key]);
      if (nested.isNotEmpty || map[key] is List) {
        return nested;
      }
    }
  }
  return const <dynamic>[];
}
