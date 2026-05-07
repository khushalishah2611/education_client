import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_config.dart';
import '../core/api_logger.dart';
import '../core/api_status.dart';
import '../models/document_type.dart';

class ApplicationApiException implements Exception {
  const ApplicationApiException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class ApplicationApiService {
  const ApplicationApiService();

  Future<Map<String, dynamic>> createBulkApplications({
    required String studentUserId,
    required List<Map<String, dynamic>> applications,
  }) async {
    final Uri uri = ApiConfig.uri('/api/student/applications/bulk').replace(
      queryParameters: <String, String>{'studentUserId': studentUserId},
    );
    final Map<String, dynamic> body = <String, dynamic>{
      'applications': applications,
    };

    final response = await http.post(
      uri,
      headers: await _jsonHeaders(),
      body: jsonEncode(body),
    );

    final decoded = _decodeMap(response.body);
    logApiCall(
      method: 'POST',
      url: uri.toString(),
      statusCode: response.statusCode,
      requestBody: body,
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw ApplicationApiException(
        statusCode: response.statusCode,
        message: decoded['message']?.toString() ?? 'Bulk create failed',
      );
    }

    return decoded;
  }

  Future<Map<String, dynamic>> fetchStudentOverview({
    required String studentUserId,
  }) async {
    final Uri uri = ApiConfig.uri(
      '/api/admin/students/${Uri.encodeComponent(studentUserId)}/overview',
    );
    final response = await http.get(uri, headers: await _authHeaders());
    final decoded = _decodeMap(response.body);

    logApiCall(
      method: 'GET',
      url: uri.toString(),
      statusCode: response.statusCode,
      requestBody: null,
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw ApplicationApiException(
        statusCode: response.statusCode,
        message: decoded['message']?.toString() ?? 'Failed to fetch overview',
      );
    }

    return decoded;
  }

  Future<String> fetchPaymentReceiptHtml({
    required String paymentId,
  }) async {
    final Uri uri = ApiConfig.uri(
      '/api/payments/${Uri.encodeComponent(paymentId)}/receipt',
    );
    final response = await http.get(uri, headers: await _authHeaders());

    logApiCall(
      method: 'GET',
      url: uri.toString(),
      statusCode: response.statusCode,
      requestBody: null,
      responseBody: response.body,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      final Map<String, dynamic> decoded = _decodeMap(response.body);
      throw ApplicationApiException(
        statusCode: response.statusCode,
        message: decoded['message']?.toString() ?? 'Failed to fetch receipt',
      );
    }

    return response.body;
  }

}

extension ApplicationApiDocumentTypes on ApplicationApiService {
  Future<List<DocumentTypeItem>> fetchDocumentTypes() async {
    final Uri uri = ApiConfig.uri('/api/student/document-types');
    final response = await http.get(uri, headers: await _authHeaders());
    final decoded = _decodeMap(response.body);
    logApiCall(
      method: 'GET',
      url: uri.toString(),
      statusCode: response.statusCode,
      requestBody: null,
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw Exception(
        decoded['message']?.toString() ?? 'Failed to fetch document types',
      );
    }

    final List<dynamic> items = decoded['items'] is List<dynamic>
        ? decoded['items'] as List<dynamic>
        : <dynamic>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(DocumentTypeItem.fromJson)
        .where((e) => e.id.isNotEmpty && e.value.isNotEmpty)
        .toList(growable: false);
  }
}

extension ApplicationApiDocuments on ApplicationApiService {
  Future<Map<String, dynamic>> uploadStudentDocument({
    required String studentUserId,
    required String type,
    required String filePath,
    required String fileName,
  }) async {
    final Uri uri = ApiConfig.uri('/api/student/documents').replace(
      queryParameters: <String, String>{'studentUserId': studentUserId},
    );

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(await _authHeaders())
      ..fields['type'] = type
      ..files.add(
        await http.MultipartFile.fromPath(
          'files',
          filePath,
          filename: fileName,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = _decodeMap(response.body);

    logApiCall(
      method: 'POST',
      url: uri.toString(),
      statusCode: response.statusCode,
      requestBody: <String, dynamic>{
        'type': type,
        'fileName': fileName,
        'filePath': filePath,
      },
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      if (response.statusCode == 413) {
        throw Exception(
            'Selected file is too large. Please upload a smaller file.');
      }
      throw Exception(
          decoded['message']?.toString() ?? 'Failed to upload document');
    }

    return decoded;
  }

  Future<List<Map<String, dynamic>>> fetchStudentDocuments({
    required String studentUserId,
  }) async {
    final Uri uri = ApiConfig.uri('/api/student/documents').replace(
      queryParameters: <String, String>{'studentUserId': studentUserId},
    );
    final response = await http.get(uri, headers: await _authHeaders());
    final decoded = _decodeMap(response.body);

    logApiCall(
      method: 'GET',
      url: uri.toString(),
      statusCode: response.statusCode,
      requestBody: null,
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw Exception(decoded['message']?.toString() ??
          'Failed to fetch student documents');
    }

    final Object? items =
        decoded['items'] ?? decoded['data'] ?? decoded['documents'] ?? decoded;
    if (items is List) {
      return items
          .whereType<Map>()
          .map((item) =>
              item.map((key, value) => MapEntry(key.toString(), value)))
          .toList(growable: false);
    }
    return const <Map<String, dynamic>>[];
  }
}

Map<String, dynamic> _decodeMap(String body) {
  try {
    final Object? parsed = jsonDecode(body);
    if (parsed is Map<String, dynamic>) {
      return parsed;
    }
  } catch (_) {}
  return <String, dynamic>{};
}

Future<Map<String, String>> _authHeaders() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String token = prefs.getString('authToken')?.trim() ?? '';
  if (token.isEmpty) return const <String, String>{};

  return <String, String>{
    'Authorization': 'Bearer $token',
  };
}

Future<Map<String, String>> _jsonHeaders() async {
  final Map<String, String> headers = <String, String>{
    'Content-Type': 'application/json'
  };
  headers.addAll(await _authHeaders());
  return headers;
}
