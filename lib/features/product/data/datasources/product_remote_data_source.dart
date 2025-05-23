import 'package:xprizo_mobile/core/network/api_client.dart';
import 'package:xprizo_mobile/core/network/api_endpoints.dart';
import 'package:xprizo_mobile/core/network/http_response_handler.dart';
import 'package:xprizo_mobile/features/product/data/exceptions/product_exception.dart';
import 'package:xprizo_mobile/features/product/data/models/add_product_request_model.dart';
import 'package:xprizo_mobile/features/product/data/models/product_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this.client, {required this.redirectUrl});
  final ApiClient client;
  final String redirectUrl;

  static const _errorMap = {
    400: ProductValidationException(message: 'Invalid request data'),
    404: ProductNotFoundException(),
    500: ProductNetworkException(details: 'Internal server error'),
  };

  Future<List<ProductModel>> fetchProductList() async {
    try {
      final response = await client.get(ApiEndpoints.productList);

      return HttpResponseHandler.handleResponse<List<ProductModel>>(
        response: response,
        onSuccess: (json) {
          if (json is List) {
            return json
                .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
                .toList();
          } else if (json is Map<String, dynamic> &&
              json.containsKey('items')) {
            final items = json['items'] as List;
            if (items.isEmpty) return [];
            return items
                .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          throw const ProductNetworkException(
            details: 'Invalid response format',
          );
        },
        errorMap: _errorMap,
        defaultErrorMessage: 'Failed to fetch product list',
      );
    } catch (e) {
      if (e is ProductException) rethrow;
      throw ProductNetworkException(details: e.toString());
    }
  }

  Future<ProductModel> getProduct(int id) async {
    try {
      final response = await client.get(ApiEndpoints.getProductById(id));

      return HttpResponseHandler.handleResponse<ProductModel>(
        response: response,
        onSuccess: (json) {
          if (json is Map<String, dynamic>) {
            return ProductModel.fromJson(json);
          }
          throw const ProductNetworkException(
            details: 'Invalid response format',
          );
        },
        errorMap: _errorMap,
        defaultErrorMessage: 'Failed to fetch product',
      );
    } catch (e) {
      if (e is ProductException) rethrow;
      throw ProductNetworkException(details: e.toString());
    }
  }

  Future<void> addProduct(AddProductRequestModel model) async {
    try {
      final response = await client.post(
        ApiEndpoints.addProduct,
        body: model.toJson(),
      );

      HttpResponseHandler.handleEmptyResponse(
        response: response,
        errorMap: _errorMap,
        defaultErrorMessage: 'Failed to add product',
      );
    } catch (e) {
      if (e is ProductException) rethrow;
      throw ProductNetworkException(details: e.toString());
    }
  }

  Future<void> setRedirectUrl(int id) async {
    try {
      final response = await client.put(
        ApiEndpoints.setRedirectLinkForProduct(id),
        params: {'value': redirectUrl},
      );

      HttpResponseHandler.handleEmptyResponse(
        response: response,
        errorMap: _errorMap,
        defaultErrorMessage: 'Failed to set product redirect link',
      );
    } catch (e) {
      if (e is ProductException) rethrow;
      throw ProductNetworkException(details: e.toString());
    }
  }

  // Future<List<ProductModel>> fetchProductList() async {
  //   await Future<void>.delayed(
  //     const Duration(seconds: 5),
  //   ); // simulate network delay
  //   return [
  //     ProductModel(
  //       id: 1,
  //       description: 'Alexa Echo Show',
  //       contactId: 102,
  //       userName: 'JaneSmith',
  //       amount: 120,
  //       currencyCode: 'USD',
  //       symbol: '',
  //       reference: 'DMK2023',
  //       routingCode: 'RT002',
  //       token: 'xyz789',
  //       paymentUrl: 'https://google.com',
  //       redirectUrl: 'https://app.example.com/thank-you',
  //       isInactive: false,
  //     ),
  //     ProductModel(
  //       id: 2,
  //       description: 'Digital Marketing Toolkit',
  //       contactId: 102,
  //       userName: 'JaneSmith',
  //       amount: 99,
  //       currencyCode: 'USD',
  //       symbol: '',
  //       reference: 'DMK2023',
  //       routingCode: 'RT002',
  //       token: 'xyz789',
  //       paymentUrl: 'https://payment.example.com',
  //       redirectUrl: 'https://app.example.com/thank-you',
  //       isInactive: false,
  //     ),
  //     ProductModel(
  //       id: 3,
  //       description: 'Digital Marketing Toolkit',
  //       contactId: 102,
  //       userName: 'JaneSmith',
  //       amount: 99,
  //       currencyCode: 'USD',
  //       symbol: '',
  //       reference: 'DMK2023',
  //       routingCode: 'RT002',
  //       token: 'xyz789',
  //       paymentUrl: 'https://payment.example.com',
  //       redirectUrl: 'https://app.example.com/thank-you',
  //       isInactive: false,
  //     ),
  //   ];
  // }

  // Future<ProductModel> getProduct(int id) async {
  //   return ProductModel(
  //     id: id,
  //     description: 'Digital Marketing Toolkit',
  //     contactId: 102,
  //     userName: 'JaneSmith',
  //     amount: 99,
  //     currencyCode: 'USD',
  //     symbol: '',
  //     reference: 'DMK2023',
  //     routingCode: 'RT002',
  //     token: 'xyz789',
  //     paymentUrl: 'https://payment.example.com',
  //     redirectUrl: 'https://app.example.com/thank-you',
  //     isInactive: false,
  //   );
  // }

  // Future<void> addProduct(AddProductRequestModel model) async {
  //   await Future<void>.delayed(
  //     const Duration(milliseconds: 500),
  //   ); // simulate post delay
  //   debugPrint('Mock add product: ${model.description}');
  // }
}
