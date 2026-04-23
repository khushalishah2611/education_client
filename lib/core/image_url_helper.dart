import 'api_config.dart';

class ImageUrlHelper {
  static String resolveUploadUrl(String? path) {
    final value = (path ?? '').trim();
    if (value.isEmpty) return '';

    if (value.startsWith('http')) {
      return value.replaceAll('/uploads//uploads/', '/uploads/');
    }

    final cleaned = value
        .replaceAll(RegExp(r'^/+'), '')
        .replaceFirst(RegExp(r'^uploads/+'), '');
    return '${ApiConfig.baseUrl}/uploads/$cleaned';
  }
}
