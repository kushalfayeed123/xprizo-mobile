import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppConfig {
  static const _apiKeyKey = 'api_key';
  static const _storage = FlutterSecureStorage();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    print('AppConfig: Starting initialization');
    if (!_isInitialized) {
      // Ensure Flutter bindings are initialized
      WidgetsFlutterBinding.ensureInitialized();
      print('AppConfig: Flutter bindings initialized');

      try {
        // Load environment variables
        await dotenv.load();
        print('AppConfig: .env file loaded successfully');
        print('AppConfig: API_KEY from env: ${dotenv.env['API_KEY']}');
      } catch (e) {
        print('AppConfig: Warning: .env file not found or error loading: $e');
        // Continue without .env file
      }
      _isInitialized = true;
    }

    try {
      print('AppConfig: Checking secure storage for API key');
      final storedApiKey = await _storage.read(key: _apiKeyKey);
      print('AppConfig: API key from storage: $storedApiKey');

      final envApiKey = dotenv.env['API_KEY'];
      if (storedApiKey != envApiKey && envApiKey != null) {
        print('AppConfig: Updating stored API key with env value');
        await _storage.write(key: _apiKeyKey, value: envApiKey);
        print('AppConfig: API key updated in storage');
      }
    } catch (e) {
      print('AppConfig: Failed to initialize: $e');
      rethrow;
    }
  }

  static Future<String> getApiKey() async {
    print('AppConfig: Getting API key');
    if (!_isInitialized) {
      print('AppConfig: Not initialized, initializing now');
      await initialize();
    }

    try {
      final apiKey = await _storage.read(key: _apiKeyKey);
      print(
          'AppConfig: Retrieved API key from storage: ${apiKey != null ? 'Found' : 'Not found'}');

      if (apiKey == null) {
        print('AppConfig: No API key in storage');
        throw Exception('API key not found in secure storage');
      }
      return apiKey;
    } catch (e) {
      print('AppConfig: Failed to read API key: $e');
      rethrow;
    }
  }

  static Future<void> setApiKey(String apiKey) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }

  static Future<void> clearApiKey() async {
    if (!_isInitialized) {
      await initialize();
    }
    await _storage.delete(key: _apiKeyKey);
  }
}
