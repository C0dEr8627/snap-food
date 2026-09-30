/// A normalized error returned by the Snap Foodd API client.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.errors = const {},
    this.cause,
  });
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, List<String>> errors;
  final Object? cause;
  bool get isUnauthorized => statusCode == 401 || code == 'UNAUTHORIZED';
  bool get isForbidden => statusCode == 403 || code == 'FORBIDDEN';
  bool get isNotFound => statusCode == 404 || code == 'NOT_FOUND';
  bool get isValidationError =>
      statusCode == 422 || code == 'VALIDATION_FAILED';
  bool get isRateLimited => statusCode == 429 || code == 'RATE_LIMITED';
  bool get isServerError => statusCode != null && statusCode! >= 500;
  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
