import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xprizo_mobile/core/config/app_config.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
  });

  group('AppConfig', () {
    test('getApiKey returns null when no key is stored', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

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
      when(() => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),),).thenAnswer((_) async {});

      await AppConfig.setApiKey(newKey);
      verify(() => mockStorage.write(key: any(named: 'key'), value: newKey))
          .called(1);
    });

    test('clearApiKey deletes the stored key', () async {
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      await AppConfig.clearApiKey();
      verify(() => mockStorage.delete(key: any(named: 'key'))).called(1);
    });
  });
}
