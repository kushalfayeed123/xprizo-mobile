import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppConfig {
  static bool _isInitialized = false;
  static const _apiKeyKey = 'api_key';
  static FlutterSecureStorage _storage = const FlutterSecureStorage();

  // App configuration
  static const String redirectUrl = 'myapp://payment-callback';

  static Future<void> initialize() async {
    if (!_isInitialized) {
      // Ensure Flutter bindings are initialized
      WidgetsFlutterBinding.ensureInitialized();

      try {
        // Load environment variables
        await dotenv.load();
      } catch (e) {
        debugPrint(
            'AppConfig: Warning: .env file not found or error loading: $e');
        // Continue without .env file
      }
      _isInitialized = true;
    }

    try {
      final storedApiKey = await _storage.read(key: _apiKeyKey);

      final envApiKey = dotenv.env['API_KEY'];
      if (storedApiKey != envApiKey && envApiKey != null) {
        await _storage.write(key: _apiKeyKey, value: envApiKey);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> getApiKey() async {
    if (!_isInitialized) {
      await initialize();
    }
    final storedKey = await _storage.read(key: _apiKeyKey);
    return storedKey;
  }

  static Future<void> setApiKey(String key) async {
    await _storage.write(key: _apiKeyKey, value: key);
  }

  static Future<void> clearApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }

  // For testing purposes
  static void setStorage(FlutterSecureStorage storage) {
    _storage = storage;
  }
}
