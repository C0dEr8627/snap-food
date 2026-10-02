import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/cart_models.dart';
import '../data/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  // The repository is recreated whenever the authenticated customer changes.
  // A cart from customer A therefore cannot remain in customer B's state.
  final userId = ref.watch(authUserIdProvider);
  if (userId == null || userId.isEmpty) {
    return LocalCartRepository();
  }
  return LocalCartRepository();
});

final cartControllerProvider = NotifierProvider<CartController, CartSnapshot>(
  CartController.new,
);

class CartController extends Notifier<CartSnapshot> {
  CartRepository get _repository => ref.read(cartRepositoryProvider);

  @override
  CartSnapshot build() => _repository.load();

  void addItem(CartItem item) => state = _repository.addItem(item);

  void clear() => state = _repository.clear();

  void changeQuantity(String productId, int delta) {
    CartItem? item;
    for (final candidate in state.items) {
      if (candidate.productId == productId) {
        item = candidate;
        break;
      }
    }
    if (item == null) return;
    state = _repository.setQuantity(productId, item.quantity + delta);
  }
}
