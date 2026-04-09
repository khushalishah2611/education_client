class ApiConfig {
  static const String baseUrl = 'http://arab.vedx.cloud:8000';

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
