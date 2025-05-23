import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:xprizo_mobile/core/network/api_endpoints.dart';

class ApiClient {
  ApiClient._(this._baseUrl,
      [http.Client? client, FlutterSecureStorage? storage])
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();
  static ApiClient? _instance;
  static bool _isInitializing = false;
  static Completer<void>? _initCompleter;
  final String _baseUrl;
  final http.Client _client;
  final FlutterSecureStorage _storage;
  String? _apiKey;

  static Future<ApiClient> create({
    http.Client? client,
    FlutterSecureStorage? storage,
  }) async {
    if (_instance == null) {
      // Ensure Flutter bindings are initialized
      WidgetsFlutterBinding.ensureInitialized();
      _instance = ApiClient._(ApiEndpoints.baseUrl, client, storage);
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
      _apiKey = await _storage.read(key: 'api_key');
      if (_apiKey == null) {
        throw Exception('API key not found');
      }
      _initCompleter?.complete();
    } catch (e) {
      _initCompleter?.completeError(e);
      // Don't rethrow here, let the completer handle the error
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
    final response = await _client.get(uri, headers: _withApiKey(headers));
    if (response.statusCode >= 400) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
    return response;
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.post(
      uri,
      headers: _withApiKey(headers),
      body: jsonEncode(body),
    );
    if (response.statusCode >= 400) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
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

    final response = await _client.put(
      uri,
      headers: _withApiKey(headers),
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode >= 400) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
    return response;
  }

// for testing purposes
  @visibleForTesting
  set apiKey(String? key) => _apiKey = key;

  @visibleForTesting
  String? get apiKey => _apiKey;

  @visibleForTesting
  static set instance(ApiClient? value) => _instance = value;
}
