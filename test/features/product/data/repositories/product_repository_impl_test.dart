import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xprizo_mobile/features/product/data/datasources/product_remote_data_source.dart';
import 'package:xprizo_mobile/features/product/data/models/add_product_request_model.dart';
import 'package:xprizo_mobile/features/product/data/repositories/product_repository_impl.dart';
import '../../../../helpers/test_helpers.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(mockDataSource);
  });

  group('ProductRepositoryImpl', () {
    group('fetchProductList', () {
      test('returns list of products when data source call is successful',
          () async {
        // Arrange
        final mockProducts = MockData.mockProducts;
        when(() => mockDataSource.fetchProductList())
            .thenAnswer((_) async => mockProducts);

        // Act
        final result = await repository.fetchProductList();

        // Assert
        expect(result, equals(mockProducts));
        verify(() => mockDataSource.fetchProductList()).called(1);
      });

      test('throws exception when data source call fails', () async {
        // Arrange
        when(() => mockDataSource.fetchProductList())
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => repository.fetchProductList(), throwsException);
      });
    });

    group('getProduct', () {
      test('returns product when data source call is successful', () async {
        // Arrange
        final mockProduct = createMockProduct();
        when(() => mockDataSource.getProduct(1))
            .thenAnswer((_) async => mockProduct);

        // Act
        final result = await repository.getProduct(1);

        // Assert
        expect(result, equals(mockProduct));
        verify(() => mockDataSource.getProduct(1)).called(1);
      });

      test('throws exception when data source call fails', () async {
        // Arrange
        when(() => mockDataSource.getProduct(1))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => repository.getProduct(1), throwsException);
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
        when(() => mockDataSource.addProduct(request)).thenAnswer((_) async {});

        // Act
        await repository.addProduct(request);

        // Assert
        verify(() => mockDataSource.addProduct(request)).called(1);
      });

      test('throws exception when data source call fails', () async {
        // Arrange
        final request = AddProductRequestModel(
          description: 'New Product',
          amount: 99.99,
          currencyCode: 'USD',
          reference: 'TEST123',
        );
        when(() => mockDataSource.addProduct(request))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => repository.addProduct(request), throwsException);
      });
    });

    group('setRedirectUrl', () {
      test('successfully sets redirect URL', () async {
        // Arrange
        when(() => mockDataSource.setRedirectUrl(1)).thenAnswer((_) async {});

        // Act
        await repository.setRedirectUrl(1);

        // Assert
        verify(() => mockDataSource.setRedirectUrl(1)).called(1);
      });

      test('throws exception when data source call fails', () async {
        // Arrange
        when(() => mockDataSource.setRedirectUrl(1))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => repository.setRedirectUrl(1), throwsException);
      });
    });
  });
}
