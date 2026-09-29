import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cart_models.dart';
import '../data/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return LocalCartRepository();
});

final cartControllerProvider =
    NotifierProvider<CartController, CartSnapshot>(CartController.new);

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
