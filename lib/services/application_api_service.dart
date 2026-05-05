import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/api_logger.dart';
import '../core/api_status.dart';
import '../models/document_type.dart';

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
      headers: const <String, String>{'Content-Type': 'application/json'},
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
      throw Exception(decoded['message']?.toString() ?? 'Bulk create failed');
    }

    return decoded;
  }
}

extension ApplicationApiDocumentTypes on ApplicationApiService {
  Future<List<DocumentTypeItem>> fetchDocumentTypes() async {
    final Uri uri = ApiConfig.uri('/api/student/document-types');
    final response = await http.get(uri);
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

    final List<dynamic> items =
        decoded['items'] is List<dynamic> ? decoded['items'] as List<dynamic> : <dynamic>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(DocumentTypeItem.fromJson)
        .where((e) => e.id.isNotEmpty && e.value.isNotEmpty)
        .toList(growable: false);
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
