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
      id: json['id'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      value: json['value'] as String? ?? '',
      dialCode: json['dialCode'] as String? ?? '',
      flagEmoji: json['flagEmoji'] as String? ?? '🌍',
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}
