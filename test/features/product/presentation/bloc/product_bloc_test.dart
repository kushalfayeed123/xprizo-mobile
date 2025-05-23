import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xprizo_mobile/features/product/data/models/add_product_request_model.dart';
import 'package:xprizo_mobile/features/product/domain/repositories/product_repository.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_bloc.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_event.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_state.dart';
import '../../../../helpers/test_helpers.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class FakeAddProductRequestModel extends Fake
    implements AddProductRequestModel {}

void main() {
  late ProductBloc bloc;
  late MockProductRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeAddProductRequestModel());
  });

  setUp(() {
    mockRepository = MockProductRepository();
    bloc = ProductBloc(mockRepository);
  });

  group('ProductBloc', () {
    blocTest<ProductBloc, ProductState>(
      'emits [loading, loaded] when products are fetched successfully',
      build: () {
        when(() => mockRepository.fetchProductList())
            .thenAnswer((_) async => MockData.mockProducts);
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchProductList()),
      expect: () => [
        isA<ProductLoading>(),
        isA<ProductLoaded>().having(
          (state) => state.allProducts,
          'allProducts',
          MockData.mockProducts,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [loading, error] when fetch fails',
      build: () {
        when(() => mockRepository.fetchProductList())
            .thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchProductList()),
      expect: () => [
        isA<ProductLoading>(),
        isA<ProductError>().having(
          (state) => state.message,
          'message',
          'Failed to load products',
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [loading, loaded] when product is added successfully',
      build: () {
        when(() => mockRepository.addProduct(any())).thenAnswer((_) async {});
        when(() => mockRepository.fetchProductList())
            .thenAnswer((_) async => MockData.mockProducts);
        return bloc;
      },
      act: (bloc) => bloc.add(
        AddProduct(
          AddProductRequestModel(
            description: 'New Product',
            amount: 99.99,
            currencyCode: 'USD',
            reference: 'TEST123',
          ),
        ),
      ),
      expect: () => [
        isA<ProductLoading>(),
        isA<ProductLoaded>().having(
          (state) => state.allProducts,
          'allProducts',
          MockData.mockProducts,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [loading, error] when add product fails',
      build: () {
        when(() => mockRepository.addProduct(any()))
            .thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(
        AddProduct(
          AddProductRequestModel(
            description: 'New Product',
            amount: 99.99,
            currencyCode: 'USD',
            reference: 'TEST123',
          ),
        ),
      ),
      expect: () => [
        isA<ProductLoading>(),
        isA<ProductError>().having(
          (state) => state.message,
          'message',
          'Failed to add product.',
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits loading message when loading more products',
      build: () {
        final products = MockData.mockProducts;
        return bloc
          ..emit(
            ProductLoaded(
              allProducts: products,
              filteredProducts: products,
              displayedProducts: products.sublist(0, 1),
              currentPage: 0,
              pageSize: 1,
            ),
          );
      },
      act: (bloc) => bloc.add(const LoadMoreProducts()),
      expect: () => [
        isA<ProductLoaded>().having(
          (state) => state.message,
          'message',
          'Loading more products...',
        ),
        isA<ProductLoaded>().having(
          (state) => state.messageType,
          'messageType',
          MessageType.info,
        ),
        isA<ProductLoaded>().having(
          (state) => state.displayedProducts.length,
          'displayedProducts.length',
          2,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits success message when setting redirect URL',
      build: () {
        when(() => mockRepository.setRedirectUrl(any()))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(
        const SetRedirectLink(
          1,
          message: 'Payment successful!',
          messageType: MessageType.success,
        ),
      ),
      expect: () => [
        isA<ProductLoaded>().having(
          (state) => state.message,
          'message',
          'Payment successful!',
        ),
        isA<ProductLoaded>().having(
          (state) => state.messageType,
          'messageType',
          MessageType.success,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits error message when setting redirect URL fails',
      build: () {
        when(() => mockRepository.setRedirectUrl(any()))
            .thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const SetRedirectLink(
          1,
          message: 'Payment successful!',
          messageType: MessageType.success,
        ),
      ),
      expect: () => [
        isA<ProductLoaded>().having(
          (state) => state.message,
          'message',
          'Failed to set redirect URL',
        ),
        isA<ProductLoaded>().having(
          (state) => state.messageType,
          'messageType',
          MessageType.error,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'filters products when search query is provided',
      build: () {
        final products = MockData.mockProducts;
        return bloc
          ..emit(
            ProductLoaded(
              allProducts: products,
              filteredProducts: products,
              displayedProducts: [],
              currentPage: 1,
              pageSize: 10,
            ),
          );
      },
      act: (bloc) => bloc.add(SearchProducts('Test')),
      expect: () => [
        isA<ProductLoaded>().having(
          (state) => state.filteredProducts,
          'filteredProducts',
          MockData.mockProducts,
        ),
      ],
    );
  });
}
