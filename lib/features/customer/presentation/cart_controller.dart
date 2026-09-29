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

  void changeQuantity(String productId, int delta) {
    final item = state.items.where((item) => item.productId == productId).firstOrNull;
    if (item == null) return;
    state = _repository.setQuantity(productId, item.quantity + delta);
  }
}
