import 'package:http/http.dart' as http;

class AppHttpClient {
  static http.Client _client = http.Client();

  /// Gets the active HTTP client instance.
  static http.Client get client => _client;

  /// Forcefully closes the current HTTP client and resets it.
  /// This immediately terminates any ongoing or pending requests 
  /// initiated by this client, throwing a SocketException.
  static void resetAndClose() {
    _client.close();
    _client = http.Client();
  }
}
