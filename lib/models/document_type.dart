class DocumentTypeItem {
  const DocumentTypeItem({
    required this.id,
    required this.value,
    required this.labelEn,
    required this.labelAr,
  });

  final String id;
  final String value;
  final String labelEn;
  final String labelAr;

  factory DocumentTypeItem.fromJson(Map<String, dynamic> json) {
    final String rawLabel = _readLocalizedString(
      json,
      const ['label', 'name', 'title'],
    );
    final String value = _readString(
      json,
      const ['value', 'type', 'key', 'code', 'slug'],
    );
    final String labelEn = _firstNonEmpty(<String>[
      _readString(json, const [
        'labelEn',
        'labelEN',
        'label_en',
        'nameEn',
        'nameEN',
        'name_en',
        'titleEn',
        'titleEN',
        'title_en',
        'englishLabel',
        'labelEnglish',
        'enLabel',
        'en',
      ]),
      _readNestedLocalizedString(
        json,
        const ['label', 'name', 'title'],
        const ['en', 'en_US', 'english', 'labelEn', 'nameEn', 'titleEn'],
      ),
      _containsArabic(rawLabel) ? '' : rawLabel,
      value,
    ]);
    final String labelAr = _firstNonEmpty(<String>[
      _readString(json, const [
        'labelAr',
        'labelAR',
        'label_ar',
        'nameAr',
        'nameAR',
        'name_ar',
        'titleAr',
        'titleAR',
        'title_ar',
        'arabicLabel',
        'labelArabic',
        'arLabel',
        'ar',
        'arabic',
      ]),
      _readNestedLocalizedString(
        json,
        const ['label', 'name', 'title'],
        const ['ar', 'ar_SA', 'arabic', 'labelAr', 'nameAr', 'titleAr'],
      ),
      _containsArabic(rawLabel) ? rawLabel : '',
    ]);

    return DocumentTypeItem(
      id: _readString(json, const ['id', '_id']),
      value: value.isNotEmpty ? value : labelEn,
      labelEn: labelEn,
      labelAr: labelAr,
    );
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final Object? value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value is num) {
      return value.toString();
    }
  }
  return '';
}

String _readLocalizedString(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final Object? value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

String _readNestedLocalizedString(
  Map<String, dynamic> json,
  List<String> keys,
  List<String> nestedKeys,
) {
  for (final String key in keys) {
    final Object? value = json[key];
    if (value is Map) {
      final String nested = _readString(
        Map<String, dynamic>.from(value),
        nestedKeys,
      );
      if (nested.isNotEmpty) {
        return nested;
      }
    }
  }
  return '';
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

bool _containsArabic(String value) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
}
