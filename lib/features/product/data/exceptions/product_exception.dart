class ProductException implements Exception {
  const ProductException({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final dynamic details;

  @override
  String toString() =>
      'ProductException: $message${code != null ? ' (Code: $code)' : ''}';
}

class ProductNotFoundException extends ProductException {
  const ProductNotFoundException({super.details})
      : super(
          message: 'Product not found',
          code: 'PRODUCT_NOT_FOUND',
        );
}

class ProductValidationException extends ProductException {
  const ProductValidationException({required super.message, super.details})
      : super(code: 'VALIDATION_ERROR');
}

class ProductNetworkException extends ProductException {
  const ProductNetworkException({super.details})
      : super(
          message: 'Network error occurred',
          code: 'NETWORK_ERROR',
        );
}
