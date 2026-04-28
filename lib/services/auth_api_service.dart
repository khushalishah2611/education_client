import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/api_logger.dart';
import '../core/api_status.dart';
import '../models/agreement_template.dart';
import '../models/country_master.dart';
import '../models/student_login_response.dart';

class AuthApiService {
  const AuthApiService();

  Future<List<CountryMaster>> fetchCountries() async {
    const path = '/api/admin/masters/country';
    final response = await http.get(ApiConfig.uri(path));
    logApiCall(
      method: 'GET',
      url: ApiConfig.uri(path).toString(),
      statusCode: response.statusCode,
      requestBody: null,
      responseBody: response.body,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
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
    const path = '/api/student/agreements/templates';
    final response = await http.get(ApiConfig.uri(path));
    logApiCall(
      method: 'GET',
      url: ApiConfig.uri(path).toString(),
      statusCode: response.statusCode,
      requestBody: null,
      responseBody: response.body,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw Exception('Failed to load terms and privacy.');
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> items = decoded is List<dynamic>
        ? decoded
        : (decoded as Map<String, dynamic>)['data'] as List<dynamic>? ??
              const <dynamic>[];

    return items
        .map((item) => AgreementTemplate.fromJson(item as Map<String, dynamic>))
        .where((item) => item.isActive)
        .toList(growable: false);
  }

  Future<StudentLoginResponse> createStudentForOtp({
    required String country,
    required String phone,
  }) async {
    const path = '/api/admin/students';
    final requestBody = <String, dynamic>{
      'country': country,
      'phone': phone,
      'isActive': true,
    };
    final response = await http.post(
      ApiConfig.uri(path),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    final decoded = _decodeObject(response.body);
    logApiCall(
      method: 'POST',
      url: ApiConfig.uri(path).toString(),
      statusCode: response.statusCode,
      requestBody: requestBody,
      responseBody: decoded,
    );
    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw ApiResponseException.fromResponse(
        response: response,
        requestUrl: ApiConfig.uri(path).toString(),
        requestBody: requestBody,
        responseBody: decoded,
      );
    }
    return StudentLoginResponse.fromJson(_extractResponsePayload(decoded));
  }

  Future<StudentLoginResponse> resendStudentOtp({
    required String studentId,
  }) async {
    final path = '/api/admin/students/$studentId/resend-otp';
    final response = await http.post(ApiConfig.uri(path));
    final decoded = _decodeObject(response.body);
    logApiCall(
      method: 'POST',
      url: ApiConfig.uri(path).toString(),
      statusCode: response.statusCode,
      requestBody: const <String, dynamic>{},
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw ApiResponseException.fromResponse(
        response: response,
        requestUrl: ApiConfig.uri(path).toString(),
        requestBody: const <String, dynamic>{},
        responseBody: decoded,
      );
    }

    return StudentLoginResponse.fromJson(_extractResponsePayload(decoded));
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
    logApiCall(
      method: 'POST',
      url: ApiConfig.uri(path).toString(),
      statusCode: response.statusCode,
      requestBody: requestBody,
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
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

Map<String, dynamic> _extractResponsePayload(Map<String, dynamic> decoded) {
  final dynamic data = decoded['data'];
  if (data is Map<String, dynamic>) {
    return <String, dynamic>{...decoded, ...data};
  }
  final dynamic student = decoded['student'];
  if (student is Map<String, dynamic>) {
    return <String, dynamic>{...decoded, ...student};
  }
  return decoded;
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
    final fallbackMessage =
        'Request failed with status ${response.statusCode}.';
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
