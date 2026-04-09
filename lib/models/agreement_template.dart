class AgreementTemplate {
  const AgreementTemplate({
    required this.id,
    required this.title,
    required this.content,
    required this.language,
    required this.isActive,
  });

  final String id;
  final String title;
  final String content;
  final String language;
  final bool isActive;

  factory AgreementTemplate.fromJson(Map<String, dynamic> json) {
    return AgreementTemplate(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}
