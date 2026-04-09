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

    final List<dynamic> list = _asList(decoded['data'] ?? decoded['items'] ?? decoded);
    return list
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final imagePath = _readString(item, const ['imagePath', 'imageUrl', 'image']);
          return BannerItem.fromJson(<String, dynamic>{
            ...item,
            'imageUrl': _toAbsoluteUrl(imagePath),
            'title': _readString(item, const ['title', 'name', 'caption']),
          });
        })
        .where((item) => item.imageUrl.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<HomeUniversity>> fetchUniversities() async {
    const path = '/api/admin/universitie';
    final response = await http.get(ApiConfig.uri(path));
    final decoded = _decode(response.body);
    logApiCall(
      method: 'GET',
      url: ApiConfig.uri(path).toString(),
      statusCode: response.statusCode,
      requestBody: null,
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw Exception('Failed to load universities.');
    }

    return _asList(decoded['data'] ?? decoded)
        .whereType<Map<String, dynamic>>()
        .map(HomeUniversity.fromJson)
        .where((item) => item.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<HomeProgram>> fetchPrograms() async {
    const path = '/api/admin/programs';
    final response = await http.get(ApiConfig.uri(path));
    final decoded = _decode(response.body);
    logApiCall(
      method: 'GET',
      url: ApiConfig.uri(path).toString(),
      statusCode: response.statusCode,
      requestBody: null,
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw Exception('Failed to load programs.');
    }

    return _asList(decoded['data'] ?? decoded)
        .whereType<Map<String, dynamic>>()
        .map(HomeProgram.fromJson)
        .where((item) => item.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<String>> fetchAcademicMasters() async {
    return _fetchMasterValues('/api/admin/masters/academic');
  }

  Future<List<String>> fetchCurrencies() async {
    return _fetchMasterValues('/api/admin/masters/currency');
  }

  Future<List<String>> _fetchMasterValues(String path) async {
    final response = await http.get(ApiConfig.uri(path));
    final decoded = _decode(response.body);
    logApiCall(
      method: 'GET',
      url: ApiConfig.uri(path).toString(),
      statusCode: response.statusCode,
      requestBody: null,
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw Exception('Failed to load master data from $path.');
    }

    final values = _asList(decoded['data'] ?? decoded)
        .whereType<Map<String, dynamic>>()
        .map((item) => _readString(item, const ['name', 'nameEn', 'value', 'code']))
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList(growable: false);
    return values;
  }
}

class HomeUniversity {
  const HomeUniversity({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.logoUrl,
    required this.rating,
  });

  factory HomeUniversity.fromJson(Map<String, dynamic> json) {
    final logoPath = _readString(json, const ['logoPath', 'imagePath', 'logo']);
    return HomeUniversity(
      id: _readString(json, const ['id', '_id']),
      name: _readString(json, const ['name']),
      country: _readString(json, const ['country', 'state']),
      city: _readString(json, const ['city']),
      logoUrl: _toAbsoluteUrl(logoPath),
      rating: _readDouble(json['rating']),
    );
  }

  final String id;
  final String name;
  final String country;
  final String city;
  final String logoUrl;
  final double rating;
}

class HomeProgram {
  const HomeProgram({required this.id, required this.name});

  factory HomeProgram.fromJson(Map<String, dynamic> json) {
    return HomeProgram(
      id: _readString(json, const ['id', '_id']),
      name: _readString(json, const ['name', 'programName']),
    );
  }

  final String id;
  final String name;
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

List<dynamic> _asList(dynamic value) {
  return value is List<dynamic> ? value : const <dynamic>[];
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final dynamic value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String _toAbsoluteUrl(String pathOrUrl) {
  if (pathOrUrl.isEmpty) return '';
  if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
    return pathOrUrl;
  }
  final normalized = pathOrUrl.startsWith('/') ? pathOrUrl : '/$pathOrUrl';
  return '${ApiConfig.baseUrl}$normalized';
}
