class LatestUpdate {
  const LatestUpdate({
    required this.title,
    required this.description,
    required this.createdAt,
    this.imagePath,
  });

  final String title;
  final String description;
  final String createdAt;
  final String? imagePath;

  factory LatestUpdate.fromJson(Map<String, dynamic> json) {
    return LatestUpdate(
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      imagePath: _readNullableString(json['imagePath']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'imagePath': imagePath,
    };
  }

  static String? _readNullableString(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
