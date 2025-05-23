import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xprizo_mobile/features/product/data/models/product_model.dart';
import 'package:xprizo_mobile/features/product/domain/repositories/product_repository.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_event.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  // Register state handlers
  ProductBloc(this._repository) : super(const ProductInitial()) {
    on<FetchProductList>(_onFetchProductList);
    on<AddProduct>(_onAddProduct);
    on<SearchProducts>(_onSearch);
    on<SetRedirectLink>(_onSetRedirectUrl);
    on<SortProducts>(_onSortProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
  }

  final ProductRepository _repository;
  static const _pageSize = 10;

  List<ProductModel> _sortProducts(
    List<ProductModel> products,
    String? sortBy,
    String sortOrder,
  ) {
    if (sortBy == null) return products;

    final sorted = List<ProductModel>.from(products)
      ..sort((a, b) {
        int comparison;
        switch (sortBy) {
          case 'amount':
            comparison = a.amount.compareTo(b.amount);
          case 'description':
            comparison = (a.description ?? '').compareTo(b.description ?? '');
          default:
            comparison = 0;
        }
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    return sorted;
  }

  List<ProductModel> _getPage(
    List<ProductModel> products,
    int page,
    int pageSize,
  ) {
    final start = page * pageSize;
    final end = start + pageSize;
    return products.sublist(0, end.clamp(0, products.length));
  }

  Future<void> _onSearch(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final filtered = currentState.allProducts.where((product) {
        final query = event.query.toLowerCase();
        return (product.description ?? '').toLowerCase().contains(query);
      }).toList();

      final sorted = _sortProducts(
        filtered,
        currentState.sortBy,
        currentState.sortOrder,
      );

      emit(
        currentState.copyWith(
          filteredProducts: sorted,
          displayedProducts: _getPage(sorted, 0, _pageSize),
          currentPage: 0,
        ),
      );
    }
  }

  Future<void> _onFetchProductList(
    FetchProductList event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductLoading());
      final products = await _repository.fetchProductList();
      if (products.isEmpty) {
        emit(
          const ProductLoaded(
            allProducts: [],
            filteredProducts: [],
            displayedProducts: [],
            currentPage: 0,
            pageSize: _pageSize,
          ),
        );
        return;
      }
      final sorted = _sortProducts(products, null, 'asc');

      emit(
        ProductLoaded(
          allProducts: products,
          filteredProducts: sorted,
          displayedProducts: _getPage(sorted, 0, _pageSize),
          currentPage: 0,
          pageSize: _pageSize,
        ),
      );
    } catch (e) {
      emit(const ProductError('Failed to load products'));
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductLoading());
      await _repository.addProduct(event.product);
      final products = await _repository.fetchProductList();
      final sorted = _sortProducts(products, null, 'asc');

      emit(
        ProductLoaded(
          allProducts: products,
          filteredProducts: sorted,
          displayedProducts: _getPage(sorted, 0, _pageSize),
          currentPage: 0,
          pageSize: _pageSize,
          message: 'Product added successfully',
          messageType: MessageType.success,
        ),
      );
    } catch (e) {
      emit(const ProductError('Failed to add product. Please try again.'));
    }
  }

  Future<void> _onSetRedirectUrl(
    SetRedirectLink event,
    Emitter<ProductState> emit,
  ) async {
    if (state is! ProductLoaded) return;

    final currentState = state as ProductLoaded;
    emit(currentState.copyWith());

    try {
      await _repository.setRedirectUrl(event.id);
      final updatedProduct = await _repository.getProduct(event.id);

      // Update the product in the lists
      final updatedAllProducts = currentState.allProducts.map((product) {
        return product.id == event.id ? updatedProduct : product;
      }).toList();

      final updatedFilteredProducts =
          currentState.filteredProducts.map((product) {
        return product.id == event.id ? updatedProduct : product;
      }).toList();

      final updatedDisplayedProducts =
          currentState.displayedProducts.map((product) {
        return product.id == event.id ? updatedProduct : product;
      }).toList();

      emit(
        currentState.copyWith(
          allProducts: updatedAllProducts,
          filteredProducts: updatedFilteredProducts,
          displayedProducts: updatedDisplayedProducts,
          currentProduct: updatedProduct,
          message: event.message,
          messageType: event.messageType,
        ),
      );
    } catch (e) {
      // Instead of emitting an error state, just revert to the previous state
      emit(
        currentState.copyWith(
          message: 'Failed to set redirect URL',
          messageType: MessageType.error,
        ),
      );
      rethrow;
    }
  }

  Future<void> _onSortProducts(
    SortProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final sorted = _sortProducts(
        currentState.filteredProducts,
        event.sortBy,
        event.sortOrder,
      );

      emit(
        currentState.copyWith(
          filteredProducts: sorted,
          displayedProducts: _getPage(sorted, 0, _pageSize),
          currentPage: 0,
          sortBy: event.sortBy,
          sortOrder: event.sortOrder,
        ),
      );
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      if (currentState.hasMore) {
        // Emit loading state with message
        emit(
          currentState.copyWith(
            message: 'Loading more products...',
            messageType: MessageType.info,
          ),
        );

        // Simulate network delay
        await Future<void>.delayed(const Duration(milliseconds: 500));

        final nextPage = currentState.currentPage + 1;
        final displayed = _getPage(
          currentState.filteredProducts,
          nextPage,
          _pageSize,
        );

        emit(
          currentState.copyWith(
            displayedProducts: displayed,
            currentPage: nextPage,
          ),
        );
      }
    }
  }
}
