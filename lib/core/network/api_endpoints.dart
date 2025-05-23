class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = 'https://test.xprizo.com/api';

  // Product endpoints
  static const String productList = '/Item/ProductList';
  static const String getProduct = '/Item/GetProduct';
  static const String addProduct = '/Item/AddProduct';
  static const String setRedirectLink = '/Item/SetRedirectLink';

  // Helper methods for endpoints with parameters
  static String getProductById(int id) => '$getProduct/$id';
  static String setRedirectLinkForProduct(int id) => '$setRedirectLink/$id';
}
