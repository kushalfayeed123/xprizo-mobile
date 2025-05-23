import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xprizo_mobile/core/config/app_config.dart';
import 'package:xprizo_mobile/core/network/api_endpoints.dart';

class ApiClient {
  static ApiClient? _instance;
  static bool _isInitializing = false;
  static Completer<void>? _initCompleter;
  final String _baseUrl;
  String? _apiKey;

  ApiClient._(this._baseUrl);

  static Future<ApiClient> create() async {
    print('ApiClient: Creating new instance');
    if (_instance == null) {
      print('ApiClient: No existing instance, creating new one');
      _instance = ApiClient._(ApiEndpoints.baseUrl);
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    print('ApiClient: Starting initialization');
    if (_isInitializing) {
      print('ApiClient: Already initializing, waiting for completion');
      if (_initCompleter != null) {
        await _initCompleter!.future;
      }
      return;
    }

    _isInitializing = true;
    _initCompleter = Completer<void>();

    try {
      print('ApiClient: Getting API key from AppConfig');
      _apiKey = await AppConfig.getApiKey();
      print('ApiClient: API key retrieved successfully');
      _initCompleter?.complete();
    } catch (e) {
      print('ApiClient: Failed to initialize: $e');
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
    print('ApiClient: Making GET request to $path');
    var uri = Uri.parse('$_baseUrl$path');
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    final response = await http.get(uri, headers: _withApiKey(headers));
    print('ApiClient: GET response status: ${response.statusCode}');
    return response;
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    print('ApiClient: Making POST request to $path');
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http.post(
      uri,
      headers: _withApiKey(headers),
      body: jsonEncode(body),
    );
    print('ApiClient: POST response status: ${response.statusCode}');
    return response;
  }

  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
  }) async {
    print('ApiClient: Making PUT request to $path');
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
    print('ApiClient: PUT response status: ${response.statusCode}');
    return response;
  }

  Future<Map<String, String>> _getHeaders() async {
    print('ApiClient: Getting headers');
    if (_apiKey == null) {
      print('ApiClient: API key is null, initializing');
      await _initialize();
    }
    print('ApiClient: Headers prepared with API key');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-Key': _apiKey!,
    };
  }
}
