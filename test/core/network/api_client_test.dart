import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:xprizo_mobile/core/network/api_client.dart';
import 'package:xprizo_mobile/core/network/api_endpoints.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late ApiClient apiClient;
  late MockHttpClient mockHttpClient;
  late MockFlutterSecureStorage mockStorage;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://example.com'));
    registerFallbackValue(<String, String>{});
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue('test');
  });

  setUp(() async {
    mockHttpClient = MockHttpClient();
    mockStorage = MockFlutterSecureStorage();

    // Mock the secure storage read
    when(() => mockStorage.read(key: 'api_key'))
        .thenAnswer((_) async => 'test-key');

    // Create a new instance for each test
    ApiClient.instance = null;
    apiClient = await ApiClient.create(
      client: mockHttpClient,
      storage: mockStorage,
    );

    // Verify the API key was set
    expect(apiClient.apiKey, 'test-key');
  });

  group('ApiClient', () {
    test('create returns ApiClient instance', () async {
      ApiClient.instance = null;
      final client = await ApiClient.create(
        client: mockHttpClient,
        storage: mockStorage,
      );
      expect(client, isA<ApiClient>());
    });

    test('get makes GET request with correct headers', () async {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/test');
      when(() => mockHttpClient.get(
            captureAny(),
            headers: captureAny(named: 'headers'),
          )).thenAnswer((_) async => http.Response('{"data": "test"}', 200));

      await apiClient.get('/test');

      verify(() => mockHttpClient.get(
            uri,
            headers: {
              'x-api-key': 'test-key',
              'Content-Type': 'application/json',
            },
          )).called(1);
    });

    test('post makes POST request with correct headers and body', () async {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/test');
      when(() => mockHttpClient.post(
            captureAny(),
            headers: captureAny(named: 'headers'),
            body: captureAny(named: 'body'),
          )).thenAnswer((_) async => http.Response('{"data": "test"}', 200));

      await apiClient.post('/test', body: {'key': 'value'});

      verify(() => mockHttpClient.post(
            uri,
            headers: {
              'x-api-key': 'test-key',
              'Content-Type': 'application/json',
            },
            body: '{"key":"value"}',
          )).called(1);
    });

    test('put makes PUT request with correct headers and body', () async {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/test');
      when(() => mockHttpClient.put(
            captureAny(),
            headers: captureAny(named: 'headers'),
            body: captureAny(named: 'body'),
          )).thenAnswer((_) async => http.Response('{"data": "test"}', 200));

      await apiClient.put('/test', body: {'key': 'value'});

      verify(() => mockHttpClient.put(
            uri,
            headers: {
              'x-api-key': 'test-key',
              'Content-Type': 'application/json',
            },
            body: '{"key":"value"}',
          )).called(1);
    });

    test('put with params makes PUT request with query parameters', () async {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/test?key=value');
      when(() => mockHttpClient.put(
            captureAny(),
            headers: captureAny(named: 'headers'),
            body: captureAny(named: 'body'),
          )).thenAnswer((_) async => http.Response('{"data": "test"}', 200));

      await apiClient.put('/test', params: {'key': 'value'});

      verify(() => mockHttpClient.put(
            uri,
            headers: {
              'x-api-key': 'test-key',
              'Content-Type': 'application/json',
            },
            body: null,
          )).called(1);
    });

    test('handles error responses correctly', () async {
      when(() => mockHttpClient.get(
                captureAny(),
                headers: captureAny(named: 'headers'),
              ))
          .thenAnswer(
              (_) async => http.Response('{"error": "test error"}', 400));

      expect(
        () => apiClient.get('/test'),
        throwsA(isA<Exception>()),
      );
    });

    test('handles network errors correctly', () async {
      when(() => mockHttpClient.get(
            captureAny(),
            headers: captureAny(named: 'headers'),
          )).thenThrow(Exception('Network error'));

      expect(
        () => apiClient.get('/test'),
        throwsA(isA<Exception>()),
      );
    });

    test('handles concurrent initialization', () async {
      ApiClient.instance = null;
      final completer = Completer<void>();

      // First initialization
      final firstInit = ApiClient.create(storage: mockStorage);

      // Second initialization before first completes
      final secondInit = ApiClient.create(storage: mockStorage);

      // Complete the first initialization
      completer.complete();

      final firstClient = await firstInit;
      final secondClient = await secondInit;

      expect(firstClient, same(secondClient));
    });

    test('handles query parameters correctly', () async {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/test?key=value');
      when(() => mockHttpClient.get(
            captureAny(),
            headers: captureAny(named: 'headers'),
          )).thenAnswer((_) async => http.Response('{"data": "test"}', 200));

      await apiClient.get('/test', queryParameters: {'key': 'value'});

      verify(() => mockHttpClient.get(
            uri,
            headers: {
              'x-api-key': 'test-key',
              'Content-Type': 'application/json',
            },
          )).called(1);
    });

    test('handles empty response body', () async {
      when(() => mockHttpClient.get(
            captureAny(),
            headers: captureAny(named: 'headers'),
          )).thenAnswer((_) async => http.Response('', 200));

      final response = await apiClient.get('/test');
      expect(response.body, '');
    });
  });
}
