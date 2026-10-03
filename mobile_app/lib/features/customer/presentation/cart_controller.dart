import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_transport.dart';
import '../../auth/data/session_store.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/cart_models.dart';
import '../data/cart_repository.dart';

final cartApiTransportProvider = Provider<HttpApiTransport>((ref) {
  final transport = HttpApiTransport();
  ref.onDispose(transport.close);
  return transport;
});

final cartApiClientProvider = Provider<ApiClient>((ref) {
  ref.watch(authUserIdProvider);
  return ApiClient(
    config: ApiConfig.fromEnvironment(),
    transport: ref.watch(cartApiTransportProvider),
    tokenProvider: SecureSessionStore().readToken,
  );
});

final cartRepositoryProvider = Provider<RemoteCartRepository>((ref) => RemoteCartRepository(ref.watch(cartApiClientProvider)));

final cartControllerProvider = NotifierProvider<CartController, CartSnapshot>(CartController.new);


final directCheckoutItemsProvider =
    NotifierProvider<DirectCheckoutItemsController, List<CartItem>?>(
  DirectCheckoutItemsController.new,
);

class DirectCheckoutItemsController extends Notifier<List<CartItem>?> {
  @override
  List<CartItem>? build() => null;

  void setItems(List<CartItem>? items) {
    state = items;
  }
}

class CartController extends Notifier<CartSnapshot> {
  RemoteCartRepository get _repository => ref.read(cartRepositoryProvider);

  @override
  CartSnapshot build() {
    ref.watch(authUserIdProvider);
    unawaited(_loadFromServer());
    return const CartSnapshot([]);
  }

  Future<void> _loadFromServer() async {
    try {
      final snapshot = await _repository.fetchCart();
      if (ref.mounted) state = snapshot;
    } catch (_) {}
  }

  void addItem(CartItem item) {
    final previous = state;
    final index = previous.items.indexWhere((existing) => existing.productId == item.productId);
    final currentQuantity = index < 0 ? 0 : previous.items[index].quantity;
    final nextQuantity = (currentQuantity + item.quantity).clamp(1, 99);

    state = index < 0
        ? CartSnapshot([...previous.items, item.copyWith(quantity: nextQuantity)])
        : CartSnapshot([
            for (final existing in previous.items)
              existing.productId == item.productId ? existing.copyWith(quantity: nextQuantity) : existing,
          ]);

    unawaited(() async {
      try {
        state = await _repository.addItem(productId: item.productId, quantity: nextQuantity);
      } catch (_) {
        await _loadFromServer();
      }
    }());
  }

  void removeItem(String productId) {
    final current = state;
    state = CartSnapshot(current.items.where((item) => item.productId != productId).toList(growable: false));
    unawaited(() async {
      try {
        state = await _repository.setQuantity(productId, 0);
      } catch (_) {
        await _loadFromServer();
      }
    }());
  }

  void changeQuantity(String productId, int delta) {
    final current = state;
    final index = current.items.indexWhere((item) => item.productId == productId);
    if (index < 0) return;

    final nextQuantity = current.items[index].quantity + delta;
    state = nextQuantity <= 0
        ? CartSnapshot(current.items.where((item) => item.productId != productId).toList(growable: false))
        : CartSnapshot([
            for (final item in current.items)
              item.productId == productId ? item.copyWith(quantity: nextQuantity) : item,
          ]);

    unawaited(() async {
      try {
        state = await _repository.setQuantity(productId, nextQuantity);
      } catch (_) {
        await _loadFromServer();
      }
    }());
  }

  void clear() {
    state = const CartSnapshot([]);
    unawaited(clearFromServer());
  }

  Future<void> clearFromServer() async {
    try {
      state = await _repository.clear();
    } catch (_) {
      await _loadFromServer();
    }
  }

  Future<void> refresh() => _loadFromServer();
}
