class MasterOption {
  const MasterOption({
    required this.nameEn,
    required this.nameAr,
    required this.value,
  });

  final String nameEn;
  final String nameAr;
  final String value;

  String get key => nameEn.isNotEmpty ? nameEn : value;

  String displayName({required bool isArabic}) {
    if (isArabic && nameAr.isNotEmpty) {
      return nameAr;
    }
    if (nameEn.isNotEmpty) {
      return nameEn;
    }
    if (nameAr.isNotEmpty) {
      return nameAr;
    }
    return value;
  }

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return nameEn.toLowerCase().contains(normalized) ||
        nameAr.toLowerCase().contains(normalized) ||
        value.toLowerCase().contains(normalized);
  }
}
