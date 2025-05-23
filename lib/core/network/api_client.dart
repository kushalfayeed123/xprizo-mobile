import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xprizo_mobile/core/config/app_config.dart';
import 'package:xprizo_mobile/core/network/api_endpoints.dart';

class ApiClient {
  ApiClient._(this._baseUrl);
  static ApiClient? _instance;
  static bool _isInitializing = false;
  static Completer<void>? _initCompleter;
  final String _baseUrl;
  String? _apiKey;

  static Future<ApiClient> create() async {
    if (_instance == null) {
      _instance = ApiClient._(ApiEndpoints.baseUrl);
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    if (_isInitializing) {
      if (_initCompleter != null) {
        await _initCompleter!.future;
      }
      return;
    }

    _isInitializing = true;
    _initCompleter = Completer<void>();

    try {
      _apiKey = await AppConfig.getApiKey();
      _initCompleter?.complete();
    } catch (e) {
      _initCompleter?.completeError(e);
      rethrow;
    } finally {
      _isInitializing = false;
      _initCompleter = null;
    }
  }

  /// Adds the x-api-key to all headers
  Map<String, String> _withApiKey([Map<String, String>? headers]) {
    if (_isInitializing || _apiKey == null) {
      throw Exception('API client not initialized');
    }
    return {
      'x-api-key': _apiKey!,
      'Content-Type': 'application/json',
      ...?headers,
    };
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    var uri = Uri.parse('$_baseUrl$path');
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    final response = await http.get(uri, headers: _withApiKey(headers));
    return response;
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http.post(
      uri,
      headers: _withApiKey(headers),
      body: jsonEncode(body),
    );
    return response;
  }

  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
  }) async {
    var uri = Uri.parse('$_baseUrl$path');

    // Append params as query parameters if body is not present
    if (body == null && params != null) {
      uri = uri.replace(queryParameters: params);
    }

    final response = await http.put(
      uri,
      headers: _withApiKey(headers),
      body: body != null ? jsonEncode(body) : null,
    );
    return response;
  }
}
