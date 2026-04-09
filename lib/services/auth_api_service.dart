import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/agreement_template.dart';
import '../models/country_master.dart';
import '../models/student_login_response.dart';

class AuthApiService {
  const AuthApiService();

  Future<List<CountryMaster>> fetchCountries() async {
    final response = await http.get(
      ApiConfig.uri('/api/admin/masters/country'),
    );

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw Exception('Failed to load countries.');
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> items = decoded is List<dynamic>
        ? decoded
        : (decoded as Map<String, dynamic>)['data'] as List<dynamic>? ??
            const <dynamic>[];

    return items
        .map((item) => CountryMaster.fromJson(item as Map<String, dynamic>))
        .where((item) => item.isActive)
        .toList(growable: false);
  }

  Future<List<AgreementTemplate>> fetchAgreementTemplates() async {
    final response = await http.get(
      ApiConfig.uri('/api/student/agreements/templates'),
    );

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw Exception('Failed to load terms and privacy.');
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> items = decoded is List<dynamic>
        ? decoded
        : (decoded as Map<String, dynamic>)['data'] as List<dynamic>? ??
            const <dynamic>[];

    return items
        .map((item) =>
            AgreementTemplate.fromJson(item as Map<String, dynamic>))
        .where((item) => item.isActive)
        .toList(growable: false);
  }

  Future<StudentLoginResponse> createStudentForOtp({
    required String country,
    required String phone,
  }) async {
    final requestBody = <String, dynamic>{
      'country': country,
      'phone': phone,
      'isActive': true,
    };
    final response = await http.post(
      ApiConfig.uri('/api/admin/students'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    final decoded = _decodeObject(response.body);
    if (response.statusCode < 200 || response.statusCode > 299) {
      throw ApiResponseException.fromResponse(
        response: response,
        requestUrl: ApiConfig.uri('/api/admin/students').toString(),
        requestBody: requestBody,
        responseBody: decoded,
      );
    }
    return StudentLoginResponse.fromJson(decoded);
  }

  Future<StudentLoginResponse> resendStudentOtp({
    required String studentId,
  }) async {
    final path = '/api/admin/students/$studentId/resend-otp';
    final response = await http.post(ApiConfig.uri(path));
    final decoded = _decodeObject(response.body);

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw ApiResponseException.fromResponse(
        response: response,
        requestUrl: ApiConfig.uri(path).toString(),
        requestBody: const <String, dynamic>{},
        responseBody: decoded,
      );
    }

    return StudentLoginResponse.fromJson(decoded);
  }

  Future<String> verifyStudentOtp({
    required String studentId,
    required String otp,
  }) async {
    final path = '/api/admin/students/$studentId/verify-otp';
    final requestBody = <String, dynamic>{'otp': otp};
    final response = await http.post(
      ApiConfig.uri(path),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    final decoded = _decodeObject(response.body);

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw ApiResponseException.fromResponse(
        response: response,
        requestUrl: ApiConfig.uri(path).toString(),
        requestBody: requestBody,
        responseBody: decoded,
      );
    }

    return decoded['message'] as String? ?? 'OTP verified successfully.';
  }
}

Map<String, dynamic> _decodeObject(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {
    return <String, dynamic>{};
  }
  return <String, dynamic>{};
}

class ApiResponseException implements Exception {
  ApiResponseException({
    required this.statusCode,
    required this.message,
    required this.url,
    required this.requestBody,
    required this.responseBody,
  });

  factory ApiResponseException.fromResponse({
    required http.Response response,
    required String requestUrl,
    required Map<String, dynamic> requestBody,
    required Map<String, dynamic> responseBody,
  }) {
    final dynamic apiMessage = responseBody['message'];
    final fallbackMessage = 'Request failed with status ${response.statusCode}.';
    return ApiResponseException(
      statusCode: response.statusCode,
      message: apiMessage is String ? apiMessage : fallbackMessage,
      url: requestUrl,
      requestBody: requestBody,
      responseBody: responseBody,
    );
  }

  final int statusCode;
  final String message;
  final String url;
  final Map<String, dynamic> requestBody;
  final Map<String, dynamic> responseBody;

  @override
  String toString() {
    return 'ApiResponseException(statusCode: $statusCode, message: $message, '
        'url: $url, requestBody: $requestBody, responseBody: $responseBody)';
  }
}
