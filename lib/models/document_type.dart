class DocumentTypeItem {
  const DocumentTypeItem({
    required this.id,
    required this.value,
    required this.labelEn,
    required this.labelAr,
  });

  final String id;
  final String value;
  final String labelEn;
  final String labelAr;

  factory DocumentTypeItem.fromJson(Map<String, dynamic> json) {
    return DocumentTypeItem(
      id: json['id']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      labelEn: json['labelEn']?.toString() ?? '',
      labelAr: json['labelAr']?.toString() ?? '',
    );
  }
}
