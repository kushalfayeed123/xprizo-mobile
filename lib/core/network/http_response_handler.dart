import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xprizo_mobile/features/product/data/exceptions/product_exception.dart';

class HttpResponseHandler {
  static T handleResponse<T>({
    required http.Response response,
    required T Function(dynamic json) onSuccess,
    Map<int, ProductException>? errorMap,
    String? defaultErrorMessage,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        throw const ProductNetworkException(details: 'Empty response body');
      }

      try {
        final json = jsonDecode(response.body);
        return onSuccess(json);
      } catch (e) {
        throw ProductNetworkException(details: 'Failed to parse response: $e');
      }
    }

    final error = errorMap?[response.statusCode];
    if (error != null) {
      throw error;
    }

    throw ProductNetworkException(
      details: defaultErrorMessage ??
          'Request failed with status ${response.statusCode}',
    );
  }

  static void handleEmptyResponse({
    required http.Response response,
    Map<int, ProductException>? errorMap,
    String? defaultErrorMessage,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final error = errorMap?[response.statusCode];
    if (error != null) {
      throw error;
    }

    throw ProductNetworkException(
      details: defaultErrorMessage ??
          'Request failed with status ${response.statusCode}',
    );
  }
}
