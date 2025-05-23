import 'package:flutter_test/flutter_test.dart';
import 'package:xprizo_mobile/features/product/data/models/product_list_params.dart';

void main() {
  group('ProductListParams', () {
    test('creates instance with default values', () {
      const params = ProductListParams();
      expect(params.page, 1);
      expect(params.pageSize, 10);
      expect(params.sortBy, null);
      expect(params.sortOrder, SortOrder.asc);
    });

    test('creates instance with custom values', () {
      const params = ProductListParams(
        page: 2,
        pageSize: 20,
        sortBy: 'name',
        sortOrder: SortOrder.desc,
      );
      expect(params.page, 2);
      expect(params.pageSize, 20);
      expect(params.sortBy, 'name');
      expect(params.sortOrder, SortOrder.desc);
    });

    test('converts to JSON correctly', () {
      const params = ProductListParams(
        page: 2,
        pageSize: 20,
        sortBy: 'name',
        sortOrder: SortOrder.desc,
      );
      expect(params.toJson(), {
        'page': 2,
        'pageSize': 20,
        'sortBy': 'name',
        'sortOrder': 'desc',
      });
    });
  });
}
