import 'package:xprizo_mobile/features/product/data/datasources/product_remote_data_source.dart';
import 'package:xprizo_mobile/features/product/data/models/add_product_request_model.dart';
import 'package:xprizo_mobile/features/product/data/models/product_model.dart';
import 'package:xprizo_mobile/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this.dataSource);

  final ProductRemoteDataSource dataSource;

  @override
  Future<List<ProductModel>> fetchProductList() =>
      dataSource.fetchProductList();

  @override
  Future<ProductModel> getProduct(int id) => dataSource.getProduct(id);

  @override
  Future<void> addProduct(AddProductRequestModel model) =>
      dataSource.addProduct(model);

  @override
  Future<void> setRedirectUrl(int id) => dataSource.setRedirectUrl(id);
}
