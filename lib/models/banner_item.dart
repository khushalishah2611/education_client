class BannerItem {
  const BannerItem({
    required this.id,
    required this.imageUrl,
    required this.redirectUrl,
    required this.title,
  });

  final String id;
  final String imageUrl;
  final String redirectUrl;
  final String title;

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    String readFirstString(List<String> keys) {
      for (final key in keys) {
        final dynamic value = json[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return '';
    }

    return BannerItem(
      id: readFirstString(['id', '_id']),
      imageUrl: readFirstString([
        'image',
        'imageUrl',
        'bannerImage',
        'banner_image',
        'thumbnail',
      ]),
      redirectUrl: readFirstString(['redirectUrl', 'url', 'link']),
      title: readFirstString(['title', 'name']),
    );
  }
}
