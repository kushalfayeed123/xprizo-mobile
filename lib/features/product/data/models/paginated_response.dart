class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedResponse(
      items: (json['items'] as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: json['totalItems'] as int,
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  final List<T> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;
}
