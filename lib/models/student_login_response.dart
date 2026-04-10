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

  factory StudentLoginResponse.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    final profileMap = profile is Map<String, dynamic>
        ? profile
        : const <String, dynamic>{};
    return StudentLoginResponse(
      id: json['id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      otp: json['otp'] as String? ?? '',
      otpRequired: json['otpRequired'] as bool? ?? false,
      otpStatus: json['otpStatus'] as String? ?? '',
      whatsappOtpLink: json['whatsappOtpLink'] as String? ?? '',
      existingUser: json['existingUser'] as bool? ?? false,
      country:
          (json['country'] as String? ?? profileMap['country'] as String? ?? '')
              .trim(),
      dialCode:
          (json['dialCode'] as String? ??
                  json['countryCode'] as String? ??
                  profileMap['dialCode'] as String? ??
                  '')
              .trim(),
    );
  }
}
