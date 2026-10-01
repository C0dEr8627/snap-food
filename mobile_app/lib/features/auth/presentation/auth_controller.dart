import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_transport.dart';
import '../../../core/network/api_exception.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import '../data/session_store.dart';

final authSessionStoreProvider = Provider<SessionStore>((ref) => SecureSessionStore());

final authApiClientProvider = Provider<ApiClient>((ref) => ApiClient(
  config: ApiConfig.fromEnvironment(),
  transport: HttpApiTransport(),
  tokenProvider: () => ref.read(authSessionStoreProvider).readToken(),
));

final authRepositoryProvider = Provider<AuthRepository>((ref) => RemoteAuthRepository(
  ref.watch(authApiClientProvider),
  ref.watch(authSessionStoreProvider),
));

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthStatus>(AuthController.new);

class AuthStatus {
  const AuthStatus({this.user, required this.isAuthenticated});
  final AuthUser? user;
  final bool isAuthenticated;
}

class AuthController extends AsyncNotifier<AuthStatus> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AuthStatus> build() async {
    final token = await _repository.readStoredToken();
    if (token == null || token.isEmpty) return const AuthStatus(isAuthenticated: false);
    try {
      final user = await _repository.fetchCurrentUser();
      return AuthStatus(user: user, isAuthenticated: true);
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await _repository.clearStoredToken();
        return const AuthStatus(isAuthenticated: false);
      }
      rethrow;
    }
  }

  Future<void> restore() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> loginWithPassword({required String email, required String password}) async {
    await _authenticate(() => _repository.loginWithPassword(email: email, password: password));
  }

  Future<void> registerCustomer({required String name, required String email, required String password, required String passwordConfirmation}) async {
    await _authenticate(() => _repository.registerCustomer(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    ));
  }

  Future<void> _authenticate(Future<AuthSession> Function() authenticate) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await authenticate();
      await _repository.storeToken(session.token);
      try {
        final user = await _repository.fetchCurrentUser();
        return AuthStatus(user: user, isAuthenticated: true);
      } catch (_) {
        await _repository.clearStoredToken();
        rethrow;
      }
    });
  }

  /// Exchanges a Google ID token for the backend-issued bearer token.
  /// The Google credential itself is never persisted.
  Future<void> signInWithGoogleCredential(String credential) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await _repository.signInWithGoogleCredential(credential);
      await _repository.storeToken(session.token);
      try {
        final user = await _repository.fetchCurrentUser();
        return AuthStatus(user: user, isAuthenticated: true);
      } catch (_) {
        await _repository.clearStoredToken();
        rethrow;
      }
    });
  }

  Future<void> setAuthenticatedToken(String token) async {
    if (token.trim().isEmpty) {
      throw const ApiException(message: 'An application session token is required.', code: 'INVALID_TOKEN');
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.storeToken(token);
      final user = await _repository.fetchCurrentUser();
      return AuthStatus(user: user, isAuthenticated: true);
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.logout();
      return const AuthStatus(isAuthenticated: false);
    });
  }
}
