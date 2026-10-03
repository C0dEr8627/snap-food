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

/// Stable customer identity used by customer-scoped providers.
///
/// Customer data providers must depend on the authenticated user id rather
/// than only on the session storage object. This forces Riverpod to dispose
/// cached cart/order/favorite state when the signed-in account changes.
final authUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authControllerProvider);
  return auth.value?.user?.payload['id']?.toString();
});

class AuthStatus {
  const AuthStatus({this.user, required this.isAuthenticated, this.errorMessage});
  final AuthUser? user;
  final bool isAuthenticated;
  final String? errorMessage;

  String? get role => user?.payload['role']?.toString().toUpperCase();
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

  Future<void> registerCustomer({required String name, required String email, required String phone, required String password, required String passwordConfirmation}) async {
    await _authenticate(() => _repository.registerCustomer(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
    ));
  }

  Future<void> _authenticate(Future<AuthSession> Function() authenticate) async {
    state = const AsyncLoading();
    try {
      final session = await authenticate();
      await _repository.storeToken(session.token);
      try {
        final user = await _repository.fetchCurrentUser();
        state = AsyncData(AuthStatus(user: user, isAuthenticated: true));
      } catch (_) {
        await _repository.clearStoredToken();
        rethrow;
      }
    } on ApiException catch (error) {
      // Authentication failures are expected user input errors, not global
      // router/session failures. Keep the router on the login screen so the
      // UI can explain the problem instead of redirecting the user.
      state = AsyncData(AuthStatus(
        isAuthenticated: false,
        errorMessage: _friendlyAuthError(error),
      ));
    }
  }

  String _friendlyAuthError(ApiException error) {
    if (error.statusCode == 401 || error.code == 'INVALID_CREDENTIALS') {
      return 'The email or password is incorrect. Please try again.';
    }
    if (error.statusCode == 403 || error.code == 'FORBIDDEN') {
      return error.message.isNotEmpty
          ? error.message
          : 'This account is not allowed to sign in to the consumer app.';
    }
    if (error.statusCode == 429 || error.code == 'RATE_LIMITED') {
      return 'Too many sign-in attempts. Please wait a moment and try again.';
    }
    if (error.code == 'TIMEOUT' || error.code == 'NETWORK_ERROR') {
      return error.message;
    }
    return error.message.isNotEmpty
        ? error.message
        : 'We could not sign you in. Please check your details and try again.';
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

  Future<void> updateProfile({required String name, required String phone}) async {
    final current = state.value;
    if (current?.user == null || !current!.isAuthenticated) {
      throw const ApiException(message: 'Please sign in again to update your profile.', code: 'UNAUTHORIZED');
    }
    final user = await _repository.updateProfile(name: name, phone: phone);
    state = AsyncData(AuthStatus(user: user, isAuthenticated: true));
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.logout();
      return const AuthStatus(isAuthenticated: false);
    });
  }
}
