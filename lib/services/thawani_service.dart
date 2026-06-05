import 'dart:convert';

import 'package:http/http.dart' as http;

class ThawaniApiException implements Exception {
  ThawaniApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class ThawaniApiService {
  const ThawaniApiService();

  static const String baseUrl = 'https://uatcheckout.thawani.om/api/v1';
  static const String publishableKey =
      'HGvTMLDssJghr9tlN9gr4DVYt0qyBy';
  static const String _secretKey =
      'rRQ26GcsZzoEhbrP2HZvLYDbn9C9et';

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, dynamic> _decodeMap(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{'message': body};
    }
  }

  Future<String> createCheckoutSession({
    required String clientReferenceId,
    required double totalAmount,
    required String currency,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    Map<String, dynamic>? metadata,
  }) async {
    final Uri uri = _uri('/sessions');

    final Map<String, dynamic> requestBody = <String, dynamic>{
      'client_reference_id': clientReferenceId,
      'currency': currency,
      'products': <Map<String, dynamic>>[
        <String, dynamic>{
          'name': 'Application Fee',
          'unit_amount': totalAmount,
          'quantity': 1,
        }
      ],
      'metadata': <String, dynamic>{
        if (customerName.isNotEmpty) 'customer_name': customerName,
        if (customerEmail.isNotEmpty) 'customer_email': customerEmail,
        if (customerPhone.isNotEmpty) 'customer_phone': customerPhone,
        ...?metadata,
      },
      'save_card_on_success': false,
    };

    final http.Response response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'thawani-api-key': _secretKey,
      },
      body: jsonEncode(requestBody),
    );

    final Map<String, dynamic> decoded = _decodeMap(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ThawaniApiException(
        response.statusCode,
        decoded['message']?.toString() ??
            'Failed to create Thawani checkout session',
      );
    }

    final String? sessionId = _extractSessionId(decoded);
    if (sessionId == null || sessionId.isEmpty) {
      throw ThawaniApiException(
        response.statusCode,
        'Missing session_id in Thawani response',
      );
    }

    return sessionId;
  }

  Future<Map<String, dynamic>> retrieveCheckoutSession({
    required String sessionId,
  }) async {
    final Uri uri = _uri('/sessions/$sessionId');

    final http.Response response = await http.get(
      uri,
      headers: <String, String>{
        'thawani-api-key': _secretKey,
      },
    );

    final Map<String, dynamic> decoded = _decodeMap(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ThawaniApiException(
        response.statusCode,
        decoded['message']?.toString() ??
            'Failed to retrieve Thawani checkout session',
      );
    }

    return decoded;
  }

  static String checkoutUrl(String sessionId) =>
      'https://uatcheckout.thawani.om/pay/$sessionId?key=$publishableKey';

  String? _extractSessionId(Map<String, dynamic> response) {
    final Object? data = response['data'];
    if (data is Map) {
      final String? sessionId = data['session_id']?.toString();
      if (sessionId != null && sessionId.isNotEmpty) {
        return sessionId;
      }
    }

    final String? rootSessionId =
        response['session_id']?.toString() ?? response['id']?.toString();
    return (rootSessionId?.isNotEmpty == true) ? rootSessionId : null;
  }
}
