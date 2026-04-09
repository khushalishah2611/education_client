import 'package:logger/logger.dart';

final Logger _logger = Logger();

void logApiCall({
  required String method,
  required String url,
  required int statusCode,
  required Object? requestBody,
  required Object? responseBody,
}) {
  _logger.i(
    [
      'API $method $url',
      'Status: $statusCode',
      'Request: ${requestBody ?? '<empty>'}',
      'Response: $responseBody',
    ].join('\n'),
  );
}
