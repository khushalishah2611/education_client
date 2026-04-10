import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/api_logger.dart';
import '../core/api_status.dart';
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

  Future<List<HomeUniversity>> fetchUniversities({
    String? country,
    String? academic,
    String? program,
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
    addIfNotEmpty('program', program);
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

class HomeUniversity {
  const HomeUniversity({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.logoUrl,
    required this.rating,
    required this.isAccredited,
    required this.academicRequirements,
    required this.programNames,
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
      isAccredited: _readBool(json, const ['isAccredited', 'accredited']),
      academicRequirements: _parseAcademicRequirements(json['academicList']),
      programNames: _parseProgramNames(json),
    );
  }

  final String id;
  final String name;
  final String country;
  final String city;
  final String logoUrl;
  final double rating;
  final bool isAccredited;
  final List<AcademicRequirement> academicRequirements;
  final Set<String> programNames;
}

class AcademicRequirement {
  const AcademicRequirement({required this.academic, required this.minResult});

  final String academic;
  final double minResult;
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

bool _readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final dynamic value = json[key];
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    if (value is num) return value != 0;
  }
  return false;
}

List<AcademicRequirement> _parseAcademicRequirements(dynamic academicList) {
  final requirements = <AcademicRequirement>[];
  if (academicList is List<dynamic>) {
    for (final raw in academicList) {
      if (raw is! Map<String, dynamic>) continue;
      final academic = _readString(raw, const ['academicname', 'academic', 'name']);
      if (academic.isEmpty) continue;
      final minResult = _readDouble(raw['percentage']);
      requirements.add(
        AcademicRequirement(academic: academic, minResult: minResult),
      );
    }
    return requirements;
  }

  final rawText = academicList is String ? academicList : '';
  if (rawText.trim().isEmpty) return const [];

  final lines = rawText
      .replaceAll('\r', '')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty);

  for (final line in lines) {
    final parts = line.split('|').map((part) => part.trim()).toList();
    if (parts.isEmpty || parts.first.isEmpty) continue;
    final threshold =
        parts.length > 1 ? double.tryParse(parts[1].replaceAll('%', '')) : null;
    requirements.add(
      AcademicRequirement(academic: parts.first, minResult: threshold ?? 0),
    );
  }
  return requirements;
}

Set<String> _parseProgramNames(Map<String, dynamic> json) {
  final values = <String>{};
  void addProgram(dynamic raw) {
    if (raw is String) {
      final normalized = raw.trim().toLowerCase();
      if (normalized.isNotEmpty) {
        values.add(normalized);
      }
      return;
    }
    if (raw is Map<String, dynamic>) {
      final name = _readString(raw, const ['name', 'programName', 'courseName']);
      if (name.isNotEmpty) {
        values.add(name.toLowerCase());
      }
    }
  }

  addProgram(json['program']);
  addProgram(json['programName']);
  addProgram(json['courseName']);

  final programList = json['programs'];
  if (programList is List<dynamic>) {
    for (final program in programList) {
      addProgram(program);
    }
  }
  final courses = json['courses'];
  if (courses is List<dynamic>) {
    for (final course in courses) {
      if (course is Map<String, dynamic>) {
        addProgram(course['program']);
        addProgram(course['programName']);
      }
    }
  }
  final programLinks = json['programLinks'];
  if (programLinks is List<dynamic>) {
    for (final link in programLinks) {
      if (link is Map<String, dynamic>) {
        addProgram(link['program']);
        addProgram(link['programName']);
      }
    }
  }
  return values;
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
