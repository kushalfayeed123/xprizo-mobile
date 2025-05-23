class ProductListParams {
  const ProductListParams({
    this.page = 1,
    this.pageSize = 10,
    this.sortBy,
    this.sortOrder = SortOrder.asc,
  });

  final int page;
  final int pageSize;
  final String? sortBy;
  final SortOrder sortOrder;

  Map<String, dynamic> toJson() => {
        'page': page,
        'pageSize': pageSize,
        if (sortBy != null) 'sortBy': sortBy,
        'sortOrder': sortOrder.name,
      };
}

enum SortOrder {
  asc,
  desc,
}
