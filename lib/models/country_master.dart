class CountryMaster {
  const CountryMaster({
    required this.id,
    required this.nameEn,
    required this.value,
    required this.dialCode,
    required this.flagEmoji,
    required this.isActive,
  });

  final String id;
  final String nameEn;
  final String value;
  final String dialCode;
  final String flagEmoji;
  final bool isActive;

  factory CountryMaster.fromJson(Map<String, dynamic> json) {
    return CountryMaster(
      id: _readString(json, const ['id', '_id']),
      nameEn: _readString(json, const ['nameEn', 'name', 'label']),
      value: _readString(json, const ['value', 'code', 'iso2', 'isoCode']),
      dialCode: _readString(json, const ['dialCode', 'countryCode']),
      flagEmoji: _readString(json, const ['flagEmoji', 'emoji']).isNotEmpty
          ? _readString(json, const ['flagEmoji', 'emoji'])
          : '🌍',
      isActive: _readBool(
        json['isActive'] ?? json['active'] ?? json['status'],
        defaultValue: true,
      ),
    );
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

bool _readBool(dynamic value, {required bool defaultValue}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return defaultValue;
}
