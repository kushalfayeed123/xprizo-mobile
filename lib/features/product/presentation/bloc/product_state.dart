import 'package:xprizo_mobile/features/product/data/models/product_list_params.dart';
import 'package:xprizo_mobile/features/product/data/models/product_model.dart';

abstract class ProductState {
  const ProductState({
    this.message,
    this.messageType,
  });

  final String? message;
  final MessageType? messageType;
}

enum MessageType {
  error,
  success,
  info,
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  const ProductLoaded({
    required this.allProducts,
    required this.filteredProducts,
    required this.displayedProducts,
    required this.currentPage,
    required this.pageSize,
    this.sortBy,
    this.sortOrder = 'asc',
    this.currentProduct,
    super.message,
    super.messageType,
  });

  final List<ProductModel> allProducts;
  final List<ProductModel> filteredProducts;
  final List<ProductModel> displayedProducts;
  final int currentPage;
  final int pageSize;
  final String? sortBy;
  final String sortOrder;
  final ProductModel? currentProduct;

  bool get hasMore => displayedProducts.length < filteredProducts.length;

  ProductLoaded copyWith({
    List<ProductModel>? allProducts,
    List<ProductModel>? filteredProducts,
    List<ProductModel>? displayedProducts,
    int? currentPage,
    int? pageSize,
    String? sortBy,
    String? sortOrder,
    ProductModel? currentProduct,
    String? message,
    MessageType? messageType,
  }) {
    return ProductLoaded(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      displayedProducts: displayedProducts ?? this.displayedProducts,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      currentProduct: currentProduct ?? this.currentProduct,
      message: message,
      messageType: messageType,
    );
  }

  ProductListParams get listParams => ProductListParams(
        page: currentPage,
        pageSize: pageSize,
        sortBy: sortBy,
        sortOrder: sortOrder == 'asc' ? SortOrder.asc : SortOrder.desc,
      );
}

class ProductError extends ProductState {
  const ProductError(String message)
      : super(message: message, messageType: MessageType.error);
}
