import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xprizo_mobile/features/product/data/models/add_product_request_model.dart';
import 'package:xprizo_mobile/features/product/data/models/product_model.dart';
import 'package:xprizo_mobile/features/product/domain/repositories/product_repository.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_bloc.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_event.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_state.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class AddProductRequestModelFake extends Fake
    implements AddProductRequestModel {}

void main() {
  late ProductBloc bloc;
  late MockProductRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AddProductRequestModelFake());
  });

  setUp(() {
    mockRepository = MockProductRepository();
    bloc = ProductBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('ProductBloc', () {
    final testProducts = [
      ProductModel(
        id: 1,
        description: 'Test Product',
        amount: 100,
        currencyCode: 'USD',
        contactId: 1,
        userName: 'test_user',
        reference: 'REF123',
        routingCode: 'ROUTE123',
        token: 'TOKEN123',
        isInactive: false,
      ),
    ];

    test('initial state is ProductInitial', () {
      expect(bloc.state, isA<ProductInitial>());
    });

    test(
        'emits [ProductLoading, ProductLoaded] when products are fetched successfully',
        () async {
      when(() => mockRepository.fetchProductList())
          .thenAnswer((_) async => testProducts);

      bloc.add(const FetchProductList());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ProductLoading>(),
          isA<ProductLoaded>().having(
            (state) => state.allProducts,
            'allProducts',
            testProducts,
          ),
        ]),
      );
    });

    test('emits [ProductLoading, ProductError] when products fetch fails',
        () async {
      when(() => mockRepository.fetchProductList())
          .thenThrow(Exception('Failed to fetch products'));

      bloc.add(const FetchProductList());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ProductLoading>(),
          isA<ProductError>().having(
            (state) => state.message,
            'error message',
            'Failed to load products',
          ),
        ]),
      );
    });

    test(
        'emits [ProductLoading, ProductLoaded] when product is added successfully',
        () async {
      final newProduct = AddProductRequestModel(
        description: 'Test Product',
        amount: 100.0,
        currencyCode: 'USD',
        reference: 'REF123',
      );
      when(() => mockRepository.addProduct(any()))
          .thenAnswer((_) async => testProducts.first);
      when(() => mockRepository.fetchProductList())
          .thenAnswer((_) async => testProducts);

      bloc.add(AddProduct(newProduct));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ProductLoading>(),
          isA<ProductLoaded>().having(
            (state) => state.allProducts,
            'allProducts',
            testProducts,
          ),
        ]),
      );
    });

    test('emits [ProductLoading, ProductError] when product addition fails',
        () async {
      final newProduct = AddProductRequestModel(
        description: 'Test Product',
        amount: 100.0,
        currencyCode: 'USD',
        reference: 'REF123',
      );
      when(() => mockRepository.addProduct(any()))
          .thenThrow(Exception('Failed to add product'));

      bloc.add(AddProduct(newProduct));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ProductLoading>(),
          isA<ProductError>().having(
            (state) => state.message,
            'error message',
            'Failed to add product. Please try again.',
          ),
        ]),
      );
    });
  });
}
