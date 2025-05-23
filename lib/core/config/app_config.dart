import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppConfig {
  static const _apiKeyKey = 'api_key';
  static const _storage = FlutterSecureStorage();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (!_isInitialized) {
      // Ensure Flutter bindings are initialized
      WidgetsFlutterBinding.ensureInitialized();

      try {
        // Load environment variables
        await dotenv.load();
      } catch (e) {
        rethrow;
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

  static Future<String> getApiKey() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final apiKey = await _storage.read(key: _apiKeyKey);

      if (apiKey == null) {
        throw Exception('API key not found in secure storage');
      }
      return apiKey;
    } catch (e) {
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
