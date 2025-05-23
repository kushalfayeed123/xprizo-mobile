import 'package:flutter_test/flutter_test.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  group('ProductModel', () {
    test('creates a valid ProductModel with default values', () {
      final product = createMockProduct();

      expect(product.id, equals(1));
      expect(product.description, equals('Test Product'));
      expect(product.amount, equals(99.99));
      expect(product.currencyCode, equals('USD'));
      expect(product.contactId, equals(102));
      expect(product.userName, equals('TestUser'));
    });

    test('creates a valid ProductModel with custom values', () {
      final product = createMockProduct(
        id: 2,
        description: 'Custom Product',
        amount: 149.99,
        currencyCode: 'EUR',
      );

      expect(product.id, equals(2));
      expect(product.description, equals('Custom Product'));
      expect(product.amount, equals(149.99));
      expect(product.currencyCode, equals('EUR'));
    });

    test('formats price correctly', () {
      final product = createMockProduct(amount: 99);
      final formattedPrice =
          '${product.currencyCode} ${product.amount.toStringAsFixed(2)}';

      expect(formattedPrice, equals('USD 99.00'));
    });
  });
}
