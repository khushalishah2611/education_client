import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/api_logger.dart';
import '../core/api_status.dart';
import '../models/admin_university.dart';
import '../models/banner_item.dart';
import '../models/country_master.dart';
import '../models/master_option.dart';

class HomeApiService {
  const HomeApiService();

  Future<List<BannerItem>> fetchBanners({int page = 1, int limit = 10}) async {
    final Uri url = ApiConfig.uri(
      '/api/admin/banners',
    ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});
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

    final List<dynamic> list = _asList(
      decoded['data'] ?? decoded['items'] ?? decoded,
    );
    return list
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final imagePath = _readString(item, const [
            'imagePath',
            'imageUrl',
            'image',
          ]);
          return BannerItem.fromJson(<String, dynamic>{
            ...item,
            'imageUrl': _toAbsoluteUrl(imagePath),
            'title': _readString(item, const ['title', 'name', 'caption']),
          });
        })
        .where((item) => item.imageUrl.isNotEmpty)
        .toList(growable: false);
  }

  

  Future<Map<String, dynamic>> fetchLatestUpdates({int page = 1, int limit = 10}) async {
    final Uri url = ApiConfig.uri('/api/admin/latest-updates').replace(
      queryParameters: {'page': '$page', 'limit': '$limit'},
    );
    final response = await http.get(url);
    final decoded = _decode(response.body);
    logApiCall(method: 'GET', url: url.toString(), statusCode: response.statusCode, requestBody: null, responseBody: decoded);
    if (!ApiStatus.isSuccess(response.statusCode)) {
      throw Exception(decoded['message']?.toString() ?? 'Failed to load latest updates.');
    }
    return decoded;
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

    return _asList(
      decoded['data'] ??
          decoded['items'] ??
          decoded['results'] ??
          decoded['universities'] ??
          decoded,
    )
        .whereType<Map<String, dynamic>>()
        .map((item) {
          return AdminUniversity.fromJson(<String, dynamic>{
            ...item,
            'id': _readString(item, const ['id', '_id', 'universityId']),
            'name': _readString(item, const [
              'name',
              'universityName',
              'title',
              'displayName',
            ]),
            'country': _readString(item, const ['country', 'countryName']),
          });
        })
        .where((item) => (item.name ?? '').trim().isNotEmpty)
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

  Future<List<MasterOption>> fetchAcademicMasters() async {
    return _fetchMasterValues('/api/admin/masters/academic');
  }

  Future<List<MasterOption>> fetchTrackMasters() async {
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

    return _asList(
      decoded['data'] ?? decoded['items'] ?? decoded['results'] ?? decoded,
    )
        .whereType<Map<String, dynamic>>()
        .map(CountryMaster.fromJson)
        .where((item) => item.nameEn.isNotEmpty && item.isActive)
        .toList(growable: false);
  }

  Future<List<MasterOption>> _fetchMasterValues(String path) async {
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

    final seen = <String>{};
    final values = <MasterOption>[];
    for (final item in _asList(decoded['data'] ?? decoded)
        .whereType<Map<String, dynamic>>()) {
      final rawName = _readString(item, const ['name', 'title', 'label']);
      final value = _readString(item, const [
        'value',
        'code',
        'key',
        'slug',
        'nameEn',
        'nameEN',
        'name_en',
        'englishName',
        'nameEnglish',
        'name',
      ]);
      final nestedNameEn = _readNestedMasterString(
        item,
        const ['name', 'title', 'label'],
        const ['en', 'en_US', 'english', 'nameEn', 'labelEn', 'titleEn'],
      );
      final explicitNameEn = _readMasterString(item, const [
        'nameEn',
        'nameEN',
        'name_en',
        'englishName',
        'nameEnglish',
        'titleEn',
        'titleEN',
        'title_en',
        'labelEn',
        'label_en',
        'enName',
        'en',
      ]);
      final nameEn = explicitNameEn.isNotEmpty
          ? explicitNameEn
          : (nestedNameEn.isNotEmpty
              ? nestedNameEn
              : (!_containsArabic(rawName) ? rawName : value));
      final nestedNameAr = _readNestedMasterString(
        item,
        const ['name', 'title', 'label'],
        const ['ar', 'ar_SA', 'arabic', 'nameAr', 'labelAr', 'titleAr'],
      );
      final explicitNameAr = _readMasterString(item, const [
        'nameAr',
        'nameAR',
        'name_ar',
        'arabicName',
        'nameArabic',
        'titleAr',
        'titleAR',
        'title_ar',
        'labelAr',
        'label_ar',
        'arName',
        'ar',
        'arabic',
      ]);
      final nameAr = explicitNameAr.isNotEmpty
          ? explicitNameAr
          : (nestedNameAr.isNotEmpty
              ? nestedNameAr
              : (_containsArabic(rawName) ? rawName : ''));
      final key = nameEn.isNotEmpty ? nameEn : value;
      if (key.isEmpty || !seen.add(key.toUpperCase())) {
        continue;
      }
      values.add(MasterOption(nameEn: nameEn, nameAr: nameAr, value: value));
    }
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
    if (value is num) {
      return value.toString();
    }
  }
  return '';
}

String _readMasterString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final dynamic value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value is num) {
      return value.toString();
    }
  }
  return '';
}

String _readNestedMasterString(
  Map<String, dynamic> json,
  List<String> keys,
  List<String> nestedKeys,
) {
  for (final key in keys) {
    final dynamic value = json[key];
    if (value is Map) {
      final nested = _readString(Map<String, dynamic>.from(value), nestedKeys);
      if (nested.isNotEmpty) {
        return nested;
      }
    }
  }
  return '';
}

bool _containsArabic(String value) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
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
