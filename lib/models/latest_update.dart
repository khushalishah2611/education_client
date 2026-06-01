class LatestUpdatesResponse {
  final List<LatestUpdate> data;
  final Pagination pagination;
  final String message;

  const LatestUpdatesResponse({
    this.data = const <LatestUpdate>[],
    this.pagination = const Pagination(),
    this.message = '',
  });

  factory LatestUpdatesResponse.fromJson(Map<String, dynamic> json) {
    final Object? rawItems = json['data'] ?? json['items'] ?? json['results'];
    final List<LatestUpdate> updates = rawItems is List<dynamic>
        ? rawItems
            .whereType<Map>()
            .map((item) => LatestUpdate.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList(growable: false)
        : const <LatestUpdate>[];

    final Object? rawPagination = json['pagination'];

    return LatestUpdatesResponse(
      data: updates,
      pagination: rawPagination is Map
          ? Pagination.fromJson(
              Map<String, dynamic>.from(rawPagination),
            )
          : Pagination.fromItems(updates.length),
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'data': data.map((item) => item.toJson()).toList(growable: false),
      'pagination': pagination.toJson(),
      'message': message,
    };
  }
}

class LatestUpdate {
  final String id;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final String imagePath;
  final String createdAt;
  final String updatedAt;

  const LatestUpdate({
    this.id = '',
    this.title = '',
    this.titleAr = '',
    this.description = '',
    this.descriptionAr = '',
    this.imagePath = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory LatestUpdate.fromJson(Map<String, dynamic> json) {
    return LatestUpdate(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['titleEn'] ?? '').toString(),
      titleAr: (json['titleAr'] ?? '').toString(),
      description: (json['description'] ?? json['descriptionEn'] ?? '')
          .toString(),
      descriptionAr: (json['descriptionAr'] ?? '').toString(),
      imagePath: (json['imagePath'] ?? json['imageUrl'] ?? json['image'] ?? '')
          .toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'titleAr': titleAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'imagePath': imagePath,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const Pagination({
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPages = 1,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: _readInt(json['page'], fallback: 1),
      limit: _readInt(json['limit'], fallback: 10),
      total: _readInt(json['total'], fallback: 0),
      totalPages: _readInt(json['totalPages'], fallback: 1),
    );
  }

  factory Pagination.fromItems(int itemCount) {
    return Pagination(
      page: 1,
      limit: itemCount,
      total: itemCount,
      totalPages: 1,
    );
  }

  bool get hasNextPage => page < totalPages;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }

  static int _readInt(Object? value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
