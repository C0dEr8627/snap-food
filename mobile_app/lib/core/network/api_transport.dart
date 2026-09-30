import 'package:http/http.dart' as http;

/// Small transport boundary so API behavior can be tested without networking.
abstract interface class ApiTransport {
  Future<http.Response> send(http.Request request);
}

class HttpApiTransport implements ApiTransport {
  HttpApiTransport([http.Client? client]) : _client = client ?? http.Client();
  final http.Client _client;

  @override
  Future<http.Response> send(http.Request request) async {
    final streamed = await _client.send(request);
    return http.Response.fromStream(streamed);
  }

  void close() => _client.close();
}
