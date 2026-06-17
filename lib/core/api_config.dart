class ApiConfig {
  static const String baseUrl = 'https://arab.vedx.cloud';
  static const String publishableKey = 'xCn5V1Uig8kT7kRBqnloCLK9IGsOQ5';
  static const String secretKey = 'u77SBP7S4r4pu3oVBrReNtULhyOm82';
  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
