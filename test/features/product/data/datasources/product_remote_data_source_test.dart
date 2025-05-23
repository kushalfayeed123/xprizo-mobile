import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:xprizo_mobile/core/network/api_client.dart';
import 'package:xprizo_mobile/features/product/data/datasources/product_remote_data_source.dart';
import 'package:xprizo_mobile/features/product/data/models/add_product_request_model.dart';

import '../../../../helpers/test_helpers.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late ProductRemoteDataSource dataSource;
  late MockApiClient mockClient;
  const redirectUrl = 'myapp://payment-callback';

  setUp(() {
    mockClient = MockApiClient();
    dataSource = ProductRemoteDataSource(mockClient, redirectUrl: redirectUrl);
  });

  group('fetchProductList', () {
    test('returns list of products when API call is successful', () async {
      // Arrange
      final mockProducts = MockData.mockProducts;
      when(() => mockClient.get('/Item/ProductList')).thenAnswer(
        (_) async => http.Response(
          jsonEncode(mockProducts.map((p) => p.toJson()).toList()),
          200,
        ),
      );

      // Act
      final result = await dataSource.fetchProductList();

      // Assert
      expect(result.length, equals(mockProducts.length));
      verify(() => mockClient.get('/Item/ProductList')).called(1);
    });

    test('throws exception when API call fails', () async {
      // Arrange
      when(() => mockClient.get('/Item/ProductList'))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => dataSource.fetchProductList(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getProduct', () {
    test('returns product when API call is successful', () async {
      // Arrange
      final mockProduct = createMockProduct();
      when(() => mockClient.get('/Item/GetProduct/1')).thenAnswer(
        (_) async => http.Response(
          jsonEncode(mockProduct.toJson()),
          200,
        ),
      );

      // Act
      final result = await dataSource.getProduct(1);

      // Assert
      expect(result.id, equals(mockProduct.id));
      verify(() => mockClient.get('/Item/GetProduct/1')).called(1);
    });

    test('throws exception when API call fails', () async {
      // Arrange
      when(() => mockClient.get('/Item/GetProduct/1'))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => dataSource.getProduct(1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('addProduct', () {
    test('successfully adds product', () async {
      // Arrange
      final request = AddProductRequestModel(
        description: 'New Product',
        amount: 99.99,
        currencyCode: 'USD',
        reference: 'TEST123',
      );
      when(() => mockClient.post('/Item/AddProduct', body: request.toJson()))
          .thenAnswer((_) async => http.Response('', 200));

      // Act
      await dataSource.addProduct(request);

      // Assert
      verify(() => mockClient.post('/Item/AddProduct', body: request.toJson()))
          .called(1);
    });

    test('throws exception when API call fails', () async {
      // Arrange
      final request = AddProductRequestModel(
        description: 'New Product',
        amount: 99.99,
        currencyCode: 'USD',
        reference: 'TEST123',
      );
      when(() => mockClient.post('/Item/AddProduct', body: request.toJson()))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => dataSource.addProduct(request),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('setRedirectUrl', () {
    test('successfully sets redirect URL', () async {
      // Arrange
      when(
        () => mockClient.put(
          '/Item/SetRedirectLink/1',
          params: {'value': redirectUrl},
        ),
      ).thenAnswer((_) async => http.Response('', 200));

      // Act
      await dataSource.setRedirectUrl(1);

      // Assert
      verify(() => mockClient.put(
            '/Item/SetRedirectLink/1',
            params: {'value': redirectUrl},
          )).called(1);
    });

    test('throws exception when API call fails', () async {
      // Arrange
      when(() => mockClient.put(
            '/Item/SetRedirectLink/1',
            params: {'value': redirectUrl},
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => dataSource.setRedirectUrl(1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
