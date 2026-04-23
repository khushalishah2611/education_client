class ApiConfig {
  static const String baseUrl = 'https://arab.vedx.cloud';

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
