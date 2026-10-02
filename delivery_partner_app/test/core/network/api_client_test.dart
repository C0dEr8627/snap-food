import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:snap_foodd/core/network/api_client.dart';
import 'package:snap_foodd/core/network/api_exception.dart';
import 'package:snap_foodd/core/network/api_transport.dart';

void main() {
  test('API config resolves paths and query parameters', () {
    const config = ApiConfig(baseUrl: 'https://example.test/api/v1/');
    expect(
      config.resolve('/products', {'q': 'rice'}).toString(),
      'https://example.test/api/v1/products?q=rice',
    );
  });

  test('sends JSON headers, bearer token, and body', () async {
    final transport = FakeTransport((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/orders');
      expect(request.headers['accept'], 'application/json');
      expect(request.headers['content-type'], 'application/json');
      expect(request.headers['authorization'], 'Bearer session-token');
      expect(request.body, '{"items":[{"product_id":7,"quantity":2}]}');
      return http.Response('{"data":{"id":12}}', 201);
    });
    final client = ApiClient(
      config: const ApiConfig(baseUrl: 'https://example.test/api/v1'),
      transport: transport,
      tokenProvider: () => 'session-token',
    );
    expect(
      await client.post(
        'orders',
        body: {
          'items': [
            {'product_id': 7, 'quantity': 2},
          ],
        },
      ),
      {
        'data': {'id': 12},
      },
    );
  });

  test('normalizes Laravel validation errors', () async {
    final client = ApiClient(
      config: const ApiConfig(baseUrl: 'https://example.test/api/v1'),
      transport: FakeTransport(
        (_) async => http.Response(
          '{"message":"Validation failed","errors":{"address":["Required"]},"code":"VALIDATION_FAILED"}',
          422,
        ),
      ),
    );
    await expectLater(
      client.post('orders', body: const {}),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 422)
            .having((e) => e.isValidationError, 'isValidationError', true)
            .having((e) => e.errors['address'], 'address errors', ['Required']),
      ),
    );
  });

  test('normalizes unauthorized responses', () async {
    final client = ApiClient(
      config: const ApiConfig(baseUrl: 'https://example.test/api/v1'),
      transport: FakeTransport((_) async => http.Response('', 401)),
    );
    await expectLater(
      client.get('me'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.isUnauthorized, 'isUnauthorized', true)
            .having((e) => e.code, 'code', 'UNAUTHORIZED'),
      ),
    );
  });

  test('normalizes timeout and network errors', () async {
    final timeoutClient = ApiClient(
      config: const ApiConfig(
        baseUrl: 'https://example.test/api/v1',
        timeout: Duration(milliseconds: 1),
      ),
      transport: FakeTransport((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return http.Response('{}', 200);
      }),
    );
    await expectLater(
      timeoutClient.get('me'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'TIMEOUT')),
    );
    final networkClient = ApiClient(
      config: const ApiConfig(baseUrl: 'https://example.test/api/v1'),
      transport: FakeTransport(
        (_) async => throw StateError('private socket detail'),
      ),
    );
    await expectLater(
      networkClient.get('me'),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'NETWORK_ERROR'),
      ),
    );
  });
}

class FakeTransport implements ApiTransport {
  FakeTransport(this.handler);
  final Future<http.Response> Function(http.Request request) handler;
  @override
  Future<http.Response> send(http.Request request) => handler(request);
}
