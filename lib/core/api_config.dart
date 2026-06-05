class ApiConfig {
  static const String baseUrl = 'https://arab.vedx.cloud';
  static const String publishableKey = 'HGvTMLDssJghr9tlN9gr4DVYt0qyBy';
  static const String secretKey = 'rRQ26GcsZzoEhbrP2HZvLYDbn9C9et';
  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
