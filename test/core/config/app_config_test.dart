import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xprizo_mobile/core/config/app_config.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;

  setUpAll(() {
    // Register fallback value for any() matcher
    registerFallbackValue('');
  });

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    // Set up the mock storage in AppConfig
    AppConfig.setStorage(mockStorage);

    // Mock all storage methods with proper named parameters
    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});
    when(() => mockStorage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});
  });

  group('AppConfig', () {
    test('getApiKey returns null when no key is stored', () async {
      final apiKey = await AppConfig.getApiKey();
      expect(apiKey, isNull);
    });

    test('getApiKey returns stored key', () async {
      const storedKey = 'test-api-key';
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => storedKey);

      final apiKey = await AppConfig.getApiKey();
      expect(apiKey, equals(storedKey));
    });

    test('setApiKey stores the key', () async {
      const newKey = 'new-api-key';
      await AppConfig.setApiKey(newKey);
      verify(() => mockStorage.write(
            key: any(named: 'key'),
            value: newKey,
          )).called(1);
    });

    test('clearApiKey deletes the stored key', () async {
      await AppConfig.clearApiKey();
      verify(() => mockStorage.delete(key: any(named: 'key'))).called(1);
    });
  });
}
