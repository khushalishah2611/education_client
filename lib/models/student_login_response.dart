class StudentLoginResponse {
  const StudentLoginResponse({
    required this.id,
    required this.message,
    required this.otp,
    required this.otpRequired,
    required this.otpStatus,
    required this.whatsappOtpLink,
  });

  final String id;
  final String message;
  final String otp;
  final bool otpRequired;
  final String otpStatus;
  final String whatsappOtpLink;

  factory StudentLoginResponse.fromJson(Map<String, dynamic> json) {
    return StudentLoginResponse(
      id: json['id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      otp: json['otp'] as String? ?? '',
      otpRequired: json['otpRequired'] as bool? ?? false,
      otpStatus: json['otpStatus'] as String? ?? '',
      whatsappOtpLink: json['whatsappOtpLink'] as String? ?? '',
    );
  }
}
