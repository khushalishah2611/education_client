import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/agreement_template.dart';
import '../models/country_master.dart';
import '../models/student_login_response.dart';

class AuthApiService {
  const AuthApiService();

  Future<List<CountryMaster>> fetchCountries() async {
    final response = await http.get(
      ApiConfig.uri('/api/admin/masters/country'),
    );

    if (response.statusCode < 200 || response.statusCode > 299) {
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
    final response = await http.get(
      ApiConfig.uri('/api/student/agreements/templates'),
    );

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw Exception('Failed to load terms and privacy.');
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> items = decoded is List<dynamic>
        ? decoded
        : (decoded as Map<String, dynamic>)['data'] as List<dynamic>? ??
            const <dynamic>[];

    return items
        .map((item) =>
            AgreementTemplate.fromJson(item as Map<String, dynamic>))
        .where((item) => item.isActive)
        .toList(growable: false);
  }

  Future<StudentLoginResponse> createStudentForOtp({
    required String country,
    required String phone,
  }) async {
    final response = await http.post(
      ApiConfig.uri('/api/admin/students'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'country': country,
        'phone': phone,
        'isActive': true,
      }),
    );

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw Exception('Failed to create student login.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return StudentLoginResponse.fromJson(decoded);
  }
}
