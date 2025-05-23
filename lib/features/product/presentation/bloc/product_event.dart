import 'package:xprizo_mobile/features/product/data/models/add_product_request_model.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_state.dart';

abstract class ProductEvent {
  const ProductEvent();
}

class FetchProductList extends ProductEvent {
  const FetchProductList();
}

class AddProduct extends ProductEvent {
  const AddProduct(this.product);

  final AddProductRequestModel product;
}

class SearchProducts extends ProductEvent {
  const SearchProducts(this.query);

  final String query;
}

class SetRedirectLink extends ProductEvent {
  const SetRedirectLink(
    this.id, {
    this.message,
    this.messageType,
  });

  final int id;
  final String? message;
  final MessageType? messageType;
}

class SortProducts extends ProductEvent {
  const SortProducts(this.sortBy, this.sortOrder);

  final String sortBy;
  final String sortOrder;
}

class LoadMoreProducts extends ProductEvent {
  const LoadMoreProducts();
}
