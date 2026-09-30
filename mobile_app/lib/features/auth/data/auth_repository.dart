import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'auth_models.dart';
import 'session_store.dart';

abstract interface class AuthRepository {
  Future<AuthUser> fetchCurrentUser();
  Future<void> logout();
  Future<String?> readStoredToken();
  Future<void> storeToken(String token);
  Future<void> clearStoredToken();
}

class RemoteAuthRepository implements AuthRepository {
  const RemoteAuthRepository(this._client, this._sessionStore);

  final ApiClient _client;
  final SessionStore _sessionStore;

  @override
  Future<AuthUser> fetchCurrentUser() async {
    final response = await _client.get('/me');
    if (response is Map<String, dynamic>) {
      return AuthUser.fromJson(response);
    }
    throw const ApiException(
      message: 'The server returned an unexpected user response.',
      code: 'INVALID_RESPONSE',
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } finally {
      await _sessionStore.clearToken();
    }
  }

  @override
  Future<String?> readStoredToken() => _sessionStore.readToken();

  @override
  Future<void> storeToken(String token) => _sessionStore.writeToken(token);

  @override
  Future<void> clearStoredToken() => _sessionStore.clearToken();
}
