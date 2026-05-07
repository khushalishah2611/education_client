class StudentLoginResponse {
  const StudentLoginResponse({
    required this.id,
    required this.message,
    required this.otp,
    required this.otpRequired,
    required this.otpStatus,
    required this.whatsappOtpLink,
    required this.existingUser,
    required this.country,
    required this.dialCode,
    required this.accessToken,
  });

  final String id;
  final String message;
  final String otp;
  final bool otpRequired;
  final String otpStatus;
  final String whatsappOtpLink;
  final bool existingUser;
  final String country;
  final String dialCode;
  final String accessToken;

  factory StudentLoginResponse.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    final profileMap =
        profile is Map<String, dynamic> ? profile : const <String, dynamic>{};
    final country = _readString(json, const [
      'country',
      'countryName',
      'country_name',
    ]);
    final dialCode = _readString(json, const [
      'dialCode',
      'countryCode',
      'dial_code',
    ]);

    return StudentLoginResponse(
      id: _readString(json, const ['id', '_id', 'studentId']),
      message: _readString(json, const ['message']),
      otp: _readString(json, const ['otp']),
      otpRequired: _readBool(json['otpRequired']),
      otpStatus: _readString(json, const ['otpStatus']),
      whatsappOtpLink: _readString(json, const [
        'whatsappOtpLink',
        'whatsappLink',
      ]),
      existingUser: _readBool(json['existingUser']),
      country: country.isNotEmpty
          ? country
          : _readString(profileMap, const ['country']),
      dialCode: dialCode.isNotEmpty
          ? dialCode
          : _readString(profileMap, const ['dialCode', 'countryCode']),
      accessToken: _readString(json, const [
        'accessToken',
        'access_token',
        'token',
        'jwt',
      ]),
    );
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final dynamic value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value != null) {
      final normalized = value.toString().trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
  }
  return '';
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}
