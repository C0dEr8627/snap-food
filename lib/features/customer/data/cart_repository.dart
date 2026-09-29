import 'cart_models.dart';

abstract interface class CartRepository {
  CartSnapshot load();
  CartSnapshot setQuantity(String productId, int quantity);
}

class LocalCartRepository implements CartRepository {
  LocalCartRepository()
      : _items = [
          const CartItem(
            productId: 'biryani',
            name: 'Special Chicken Tikka Dum Biryani',
            description: 'Chicken • Single',
            previewPrice: 320,
            quantity: 1,
            vegetarian: false,
          ),
          const CartItem(
            productId: 'butter',
            name: 'Butter Chicken & 2 Butter Naan Combo',
            description: 'Combo • Serves 1',
            previewPrice: 280,
            quantity: 1,
            vegetarian: false,
          ),
        ];

  final List<CartItem> _items;

  @override
  CartSnapshot load() => CartSnapshot(List.unmodifiable(_items));

  @override
  CartSnapshot setQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index < 0) return load();

    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
    return load();
  }
}
