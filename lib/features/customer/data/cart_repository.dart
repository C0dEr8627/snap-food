import 'cart_models.dart';

abstract interface class CartRepository {
  CartSnapshot load();
  CartSnapshot addItem(CartItem item);
  CartSnapshot setQuantity(String productId, int quantity);
  CartSnapshot clear();
}

class LocalCartRepository implements CartRepository {
  LocalCartRepository({Iterable<CartItem> initialItems = const []})
      : _items = List<CartItem>.from(initialItems);

  final List<CartItem> _items;

  @override
  CartSnapshot load() => CartSnapshot(List.unmodifiable(_items));

  @override
  CartSnapshot addItem(CartItem item) {
    if (item.productId.trim().isEmpty) return load();
    final index = _items.indexWhere((existing) => existing.productId == item.productId);
    if (index < 0) {
      _items.add(item.copyWith(quantity: item.quantity.clamp(1, 99)));
    } else {
      final existing = _items[index];
      _items[index] = existing.copyWith(
        quantity: (existing.quantity + item.quantity).clamp(1, 99),
      );
    }
    return load();
  }

  @override
  CartSnapshot clear() {
    _items.clear();
    return load();
  }

  @override
  CartSnapshot setQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index < 0) return load();
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity.clamp(1, 99));
    }
    return load();
  }
}
