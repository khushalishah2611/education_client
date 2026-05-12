import 'api_config.dart';

class ImageUrlHelper {
  static String resolveUploadUrl(String? path) {
    final value = (path ?? '').trim();

    if (value.isEmpty) return '';

    // If already full URL
    if (value.startsWith('http')) {
      return Uri.encodeFull(
        value.replaceAll('/uploads//uploads/', '/uploads/'),
      );
    }

    String cleaned = value;

    // Convert server file path to public URL
    cleaned = cleaned.replaceAll(
      '/var/www/education_master/server/uploads',
      '${ApiConfig.baseUrl}/uploads',
    );

    // Remove duplicate uploads path
    cleaned = cleaned.replaceAll('/uploads//uploads/', '/uploads/');

    // If still not full URL
    if (!cleaned.startsWith('http')) {
      cleaned = cleaned
          .replaceAll(RegExp(r'^/+'), '')
          .replaceFirst(RegExp(r'^uploads/+'), '');

      cleaned = '${ApiConfig.baseUrl}/uploads/$cleaned';
    }

    // Encode spaces and special characters
    return Uri.encodeFull(cleaned);
  }
}