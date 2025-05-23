import 'package:xprizo_mobile/features/product/data/models/add_product_request_model.dart';
import 'package:xprizo_mobile/features/product/data/models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> fetchProductList();
  Future<ProductModel> getProduct(int id);
  Future<void> addProduct(AddProductRequestModel model);
  Future<void> setRedirectUrl(int id);
}
