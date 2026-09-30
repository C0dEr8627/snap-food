import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exception.dart';
import 'api_transport.dart';

/// Configure with --dart-define=API_BASE_URL=... for each environment.
class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 15),
  });
  factory ApiConfig.fromEnvironment() => ApiConfig(
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8000/api/v1',
    ),
  );
  final String baseUrl;
  final Duration timeout;

  Uri resolve(String path, [Map<String, String>? queryParameters]) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final relative = path.startsWith('/') ? path.substring(1) : path;
    final uri = Uri.parse('$base/$relative');
    if (queryParameters == null || queryParameters.isEmpty) return uri;
    return uri.replace(
      queryParameters: {...uri.queryParameters, ...queryParameters},
    );
  }
}

/// Shared JSON client for all repositories. Sensitive payloads are never logged.
class ApiClient {
  ApiClient({
    required ApiConfig config,
    required ApiTransport transport,
    FutureOr<String?> Function()? tokenProvider,
  }) : _config = config,
       _transport = transport,
       _tokenProvider = tokenProvider;
  final ApiConfig _config;
  final ApiTransport _transport;
  final FutureOr<String?> Function()? _tokenProvider;

  Future<Object?> get(String path, {Map<String, String>? queryParameters}) =>
      request('GET', path, queryParameters: queryParameters);
  Future<Object?> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
  }) => request('POST', path, body: body, queryParameters: queryParameters);

  Future<Object?> request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final token = await _tokenProvider?.call();
      final request =
          http.Request(
              method.toUpperCase(),
              _config.resolve(path, queryParameters),
            )
            ..headers.addAll({
              'Accept': 'application/json',
              if (body != null) 'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
              ...?headers,
            });
      if (body != null) request.body = jsonEncode(body);
      final response = await _transport.send(request).timeout(_config.timeout);
      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } on TimeoutException catch (error) {
      throw ApiException(
        message: 'The request timed out. Check your connection and try again.',
        code: 'TIMEOUT',
        cause: error,
      );
    } catch (error) {
      throw ApiException(
        message: 'Unable to connect. Check your connection and try again.',
        code: 'NETWORK_ERROR',
        cause: error,
      );
    }
  }

  Object? _decodeResponse(http.Response response) {
    Object? decoded;
    if (response.body.trim().isEmpty) {
      decoded = null;
    } else {
      try {
        decoded = jsonDecode(response.body);
      } on FormatException catch (error) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          throw ApiException(
            message: 'The server returned an invalid response.',
            statusCode: response.statusCode,
            code: 'INVALID_RESPONSE',
            cause: error,
          );
        }
        throw ApiException(
          message: _fallbackMessage(response.statusCode),
          statusCode: response.statusCode,
          code: _fallbackCode(response.statusCode),
        );
      }
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return decoded;
    if (decoded is Map<String, dynamic>) {
      final errors = <String, List<String>>{};
      final rawErrors = decoded['errors'];
      if (rawErrors is Map) {
        for (final entry in rawErrors.entries) {
          final value = entry.value;
          if (value is List) {
            errors[entry.key.toString()] = value
                .map((item) => item.toString())
                .toList();
          } else if (value != null) {
            errors[entry.key.toString()] = [value.toString()];
          }
        }
      }
      throw ApiException(
        message: decoded['message'] is String
            ? decoded['message'] as String
            : _fallbackMessage(response.statusCode),
        statusCode: response.statusCode,
        code: decoded['code'] is String
            ? decoded['code'] as String
            : _fallbackCode(response.statusCode),
        errors: errors,
      );
    }
    throw ApiException(
      message: _fallbackMessage(response.statusCode),
      statusCode: response.statusCode,
      code: _fallbackCode(response.statusCode),
    );
  }

  String _fallbackMessage(int status) => switch (status) {
    401 => 'Please sign in again.',
    403 => 'You do not have permission to perform this action.',
    404 => 'The requested resource was not found.',
    409 => 'This action conflicts with the current state.',
    422 => 'Please check the information and try again.',
    429 => 'Too many requests. Please wait and try again.',
    >= 500 => 'The service is temporarily unavailable.',
    _ => 'The request could not be completed.',
  };

  String _fallbackCode(int status) => switch (status) {
    401 => 'UNAUTHORIZED',
    403 => 'FORBIDDEN',
    404 => 'NOT_FOUND',
    409 => 'CONFLICT',
    422 => 'VALIDATION_FAILED',
    429 => 'RATE_LIMITED',
    >= 500 => 'SERVER_ERROR',
    _ => 'HTTP_ERROR',
  };
}
