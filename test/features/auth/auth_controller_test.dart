import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:snap_foodd/core/network/api_exception.dart';
import 'package:snap_foodd/features/auth/data/auth_models.dart';
import 'package:snap_foodd/features/auth/data/auth_repository.dart';
import 'package:snap_foodd/features/auth/presentation/auth_controller.dart';


class _FakeRepository implements AuthRepository {
  _FakeRepository({this.token});
  String? token;
  AuthUser user = const AuthUser({});  bool logoutCalled = false;

  @override
  Future<AuthUser> fetchCurrentUser() async {
    if (token == 'expired') {
      throw const ApiException(
        message: 'Unauthorized',
        code: 'UNAUTHORIZED',
        statusCode: 401,
      );
    }
    return user;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    token = null;
  }

  @override
  Future<void> clearStoredToken() async => token = null;
  @override
  Future<String?> readStoredToken() async => token;
  @override
  Future<void> storeToken(String value) async => token = value;
}

void main() {
  test('restores authenticated session from a stored token', () async {
    final repository = _FakeRepository(token: 'token');
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final state =
        await container.read(authControllerProvider.future);

    expect(state.isAuthenticated, isTrue);
    expect(state.user, isNotNull);
  });

  test('clears expired token and becomes signed out', () async {
    final repository = _FakeRepository(token: 'expired');
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final state =
        await container.read(authControllerProvider.future);

    expect(state.isAuthenticated, isFalse);
    expect(repository.token, isNull);
  });

  test('logout clears authenticated state', () async {
    final repository = _FakeRepository(token: 'token');
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container.read(authControllerProvider.notifier).logout();

    final state = container.read(authControllerProvider);
    expect(state.requireValue.isAuthenticated, isFalse);
    expect(repository.logoutCalled, isTrue);
  });
}
