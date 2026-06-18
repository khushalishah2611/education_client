import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_config.dart';
import '../core/api_logger.dart';
import '../core/api_status.dart';
import '../core/student_session.dart';

class StudentApiException implements Exception {
  const StudentApiException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class StudentApiService {
  const StudentApiService();

  Future<Map<String, dynamic>> updateProfileLanguage({
    required String language,
  }) async {
    final String studentUserId = await StudentSession.currentStudentUserId();
    const path = '/api/student/profile/language';
    final Uri uri = ApiConfig.uri('$path?studentUserId=$studentUserId');
    final Map<String, dynamic> body = <String, dynamic>{
      'language': language,
    };
    final Map<String, String> headers = await _jsonAuthHeaders();

    final http.Response response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    final Map<String, dynamic> decoded = _decodeMap(response.body);

    logApiCall(
      method: 'PATCH',
      url: uri.toString(),
      statusCode: response.statusCode,
      requestBody: body,
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw StudentApiException(
        statusCode: response.statusCode,
        message: decoded['message']?.toString() ??
            'Failed to update language.',
      );
    }

    return decoded;
  }

  Future<Map<String, dynamic>> submitUniversityRating({
    required String universityId,
    required double rating,
    required String remark,
  }) async {
    final Uri uri = ApiConfig.uri(
      '/api/universities/${Uri.encodeComponent(universityId)}/rating',
    );
    final Map<String, String> headers = await _authHeaders();

    final http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields['rating'] = rating.toString()
      ..fields['remark'] = remark.trim();

    final http.StreamedResponse streamed = await request.send();
    final http.Response response = await http.Response.fromStream(streamed);
    final Map<String, dynamic> decoded = _decodeMap(response.body);

    logApiCall(
      method: 'POST',
      url: uri.toString(),
      statusCode: response.statusCode,
      requestBody: request.fields,
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw StudentApiException(
        statusCode: response.statusCode,
        message: decoded['message']?.toString() ?? 'Failed to submit rating.',
      );
    }

    return decoded;
  }

  Future<Map<String, String>> _authHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('authToken')?.trim() ?? '';

    return <String, String>{
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _jsonAuthHeaders() async {
    final Map<String, String> headers = await _authHeaders();
    return <String, String>{
      ...headers,
      'Content-Type': 'application/json',
    };
  }
}

Map<String, dynamic> _decodeMap(String body) {
  try {
    final Object? parsed = jsonDecode(body);
    if (parsed is Map) {
      return Map<String, dynamic>.from(parsed);
    }
  } catch (_) {}
  return <String, dynamic>{};
}
