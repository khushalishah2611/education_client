import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/api_logger.dart';
import '../core/api_status.dart';
import '../models/admin_university.dart';
import '../models/banner_item.dart';
import '../models/country_master.dart';

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

  Future<List<AdminUniversity>> fetchUniversities({
    String? country,
    String? academic,
    String? track,
    String? search,
  }) async {
    const path = '/api/admin/universities';
    final queryParameters = <String, String>{};
    void addIfNotEmpty(String key, String? value) {
      final normalized = value?.trim() ?? '';
      if (normalized.isNotEmpty) {
        queryParameters[key] = normalized;
      }
    }

    addIfNotEmpty('country', country);
    addIfNotEmpty('academic', academic);
    addIfNotEmpty('track', track);
    addIfNotEmpty('search', search);

    final uri = ApiConfig.uri(path).replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    final response = await http.get(uri);
    final decoded = _decode(response.body);
    logApiCall(
      method: 'GET',
      url: uri.toString(),
      statusCode: response.statusCode,
      requestBody: null,
      responseBody: decoded,
    );

    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw Exception('Failed to load universities.');
    }

    return _asList(decoded['data'] ?? decoded)
        .whereType<Map<String, dynamic>>()
        .map(AdminUniversity.fromJson)
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
        .map(_homeProgramFromJson)
        .where((item) => item.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<String>> fetchAcademicMasters() async {
    return _fetchMasterValues('/api/admin/masters/academic');
  }

  Future<List<String>> fetchTrackMasters() async {
    return _fetchMasterValues('/api/admin/masters/track');
  }

  Future<List<CountryMaster>> fetchCountries() async {
    const path = '/api/admin/masters/country';
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
      throw Exception('Failed to load countries.');
    }

    return _asList(decoded['data'] ?? decoded)
        .whereType<Map<String, dynamic>>()
        .map(CountryMaster.fromJson)
        .where((item) => item.nameEn.isNotEmpty && item.isActive)
        .toList(growable: false);
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

HomeProgram _homeProgramFromJson(Map<String, dynamic> json) {
  return HomeProgram(
    id: _readString(json, const ['id', '_id']),
    name: _readString(json, const ['name', 'programName']),
  );
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

String _toAbsoluteUrl(String pathOrUrl) {
  if (pathOrUrl.isEmpty) return '';
  if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
    return pathOrUrl;
  }
  final normalized = pathOrUrl.startsWith('/') ? pathOrUrl : '/$pathOrUrl';
  return '${ApiConfig.baseUrl}$normalized';
}

class HomeProgram {
  const HomeProgram({required this.id, required this.name});

  final String id;
  final String name;
}
