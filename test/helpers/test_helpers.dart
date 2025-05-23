import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xprizo_mobile/features/product/data/models/product_model.dart';

/// Creates a mock [ProductModel] for testing
ProductModel createMockProduct({
  int id = 1,
  String description = 'Test Product',
  double amount = 99.99,
  String currencyCode = 'USD',
}) {
  return ProductModel(
    id: id,
    description: description,
    amount: amount,
    currencyCode: currencyCode,
    contactId: 102,
    userName: 'TestUser',
    symbol: '',
    reference: 'TEST123',
    routingCode: 'RT001',
    token: 'test-token',
    paymentUrl: 'https://test.com/pay',
    redirectUrl: 'https://test.com/redirect',
    isInactive: false,
  );
}

/// Extension methods for common test operations
extension WidgetTesterExtension on WidgetTester {
  /// Pumps the widget and waits for animations to complete
  Future<void> pumpAndSettle() async {
    await pump();
    await pumpAndSettle();
  }

  /// Finds a widget by its key
  Finder findByKey(Key key) => find.byKey(key);

  /// Finds a widget by its type
  Finder findByType<T>() => find.byType(T);

  /// Finds a widget by its text
  Finder findByText(String text) => find.text(text);
}

/// Mock data for testing
class MockData {
  static List<ProductModel> get mockProducts => [
        createMockProduct(),
        createMockProduct(id: 2),
        createMockProduct(id: 3),
      ];
}
