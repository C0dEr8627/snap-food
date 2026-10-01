import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'auth_models.dart';
import 'session_store.dart';

abstract interface class AuthRepository {
  Future<AuthSession> loginWithPassword({required String email, required String password});
  Future<AuthSession> registerCustomer({required String name, required String email, required String password, required String passwordConfirmation});
  Future<AuthSession> signInWithGoogleCredential(String credential);
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
  Future<AuthSession> loginWithPassword({required String email, required String password}) async {
    final response = await _client.post('/auth/login', body: {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
    return _parseSession(response);
  }

  @override
  Future<AuthSession> registerCustomer({required String name, required String email, required String password, required String passwordConfirmation}) async {
    final response = await _client.post('/auth/register', body: {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return _parseSession(response);
  }

  AuthSession _parseSession(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map) {
        final token = data['token'];
        final user = data['user'];
        if (token is String && token.isNotEmpty && user is Map) {
          return AuthSession(
            token: token,
            user: AuthUser.fromJson(Map<String, dynamic>.from(user)),
          );
        }
      }
    }
    throw const ApiException(
      message: 'The server returned an unexpected authentication response.',
      code: 'INVALID_RESPONSE',
    );
  }

  @override
  Future<AuthSession> signInWithGoogleCredential(String credential) async {
    final normalized = credential.trim();
    if (normalized.isEmpty) {
      throw const ApiException(
        message: 'A Google sign-in credential is required.',
        code: 'INVALID_GOOGLE_CREDENTIAL',
      );
    }
    final response = await _client.post(
      '/auth/google',
      body: {'credential': normalized},
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map) {
        final token = data['token'];
        final user = data['user'];
        if (token is String && token.isNotEmpty && user is Map) {
          return AuthSession(
            token: token,
            user: AuthUser.fromJson(Map<String, dynamic>.from(user)),
          );
        }
      }
    }
    throw const ApiException(
      message: 'The server returned an unexpected sign-in response.',
      code: 'INVALID_RESPONSE',
    );
  }

  @override
  Future<AuthUser> fetchCurrentUser() async {
    final response = await _client.get('/me');
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map) {
        final user = data['user'];
        if (user is Map) {
          return AuthUser.fromJson(Map<String, dynamic>.from(user));
        }
        if (data['id'] != null) {
          return AuthUser.fromJson(Map<String, dynamic>.from(data));
        }
      }
      if (response['id'] != null) return AuthUser.fromJson(response);
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
