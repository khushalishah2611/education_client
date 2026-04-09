import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/api_logger.dart';
import '../core/api_status.dart';
import '../models/banner_item.dart';

class HomeApiService {
  const HomeApiService();

  Future<List<BannerItem>> fetchBanners({int page = 1, int limit = 10}) async {
    final Uri url = ApiConfig.uri('/api/admin/banners').replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
      },
    );
    final response = await http.get(url);
    final decoded = _decode(response.body);

    logApiCall(
      method: 'GET',
      url: url.toString(),
      statusCode: response.statusCode,
      requestBody: null,
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw Exception('Failed to load banners.');
    }

    final dynamic payload = decoded['data'] ?? decoded['items'] ?? decoded;
    final List<dynamic> list = payload is List<dynamic> ? payload : const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(BannerItem.fromJson)
        .where((item) => item.imageUrl.isNotEmpty)
        .toList(growable: false);
  }
}

Map<String, dynamic> _decode(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is List<dynamic>) {
      return <String, dynamic>{'data': decoded};
    }
  } catch (_) {
    return <String, dynamic>{};
  }
  return <String, dynamic>{};
}
