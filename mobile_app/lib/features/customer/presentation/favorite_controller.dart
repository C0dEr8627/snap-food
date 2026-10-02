import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_transport.dart';
import '../../auth/data/session_store.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/catalogue_models.dart';
import '../data/favorite_repository.dart';

final favoriteApiTransportProvider = Provider<HttpApiTransport>((ref) {
  final transport = HttpApiTransport();
  ref.onDispose(transport.close);
  return transport;
});

final favoriteApiClientProvider = Provider<ApiClient>((ref) {
  // Depend on the authenticated user id so a new login creates a fresh
  // client/controller state instead of retaining the previous user's data.
  ref.watch(authUserIdProvider);
  return ApiClient(
    config: ApiConfig.fromEnvironment(),
    transport: ref.watch(favoriteApiTransportProvider),
    tokenProvider: SecureSessionStore().readToken,
  );
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return RemoteFavoriteRepository(ref.watch(favoriteApiClientProvider));
});

final favoriteControllerProvider =
    AsyncNotifierProvider<FavoriteController, FavoriteState>(
  FavoriteController.new,
);

class FavoriteState {
  const FavoriteState({this.products = const []});
  final List<CatalogueProduct> products;

  bool contains(int productId) => products.any((product) => product.id == productId);
}

class FavoriteController extends AsyncNotifier<FavoriteState> {
  FavoriteRepository get _repository => ref.read(favoriteRepositoryProvider);

  @override
  Future<FavoriteState> build() async {
    try {
      return FavoriteState(products: await _repository.fetchFavorites());
    } catch (_) {
      return const FavoriteState();
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return FavoriteState(products: await _repository.fetchFavorites());
    });
  }

  Future<void> toggle(CatalogueProduct product) async {
    final current = state.value ?? const FavoriteState();
    final isFavorite = current.contains(product.id);

    if (isFavorite) {
      state = AsyncData(
        FavoriteState(
          products: current.products.where((item) => item.id != product.id).toList(growable: false),
        ),
      );
      try {
        await _repository.removeFavorite(product.id);
      } catch (_) {
        state = AsyncData(current);
      }
      return;
    }

    state = AsyncData(
      FavoriteState(products: [...current.products, product]),
    );
    try {
      await _repository.addFavorite(product.id);
    } catch (_) {
      state = AsyncData(current);
    }
  }
}
