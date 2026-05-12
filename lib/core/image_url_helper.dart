import 'api_config.dart';

class ImageUrlHelper {
  static String resolveUploadUrl(String? path) {
    final value = (path ?? '').trim();

    if (value.isEmpty) return '';

    // If already full URL
    if (value.startsWith('http')) {
      return Uri.encodeFull(value);
    }

    // Replace server path with public URL path
    String cleaned = value.replaceAll(
      '/var/www/education_master/server/uploads',
      '${ApiConfig.baseUrl}/uploads',
    );

    // Encode spaces and special characters
    return Uri.encodeFull(cleaned);
  }
}