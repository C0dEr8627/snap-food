/// A local cart line.
///
/// The cart remains client-side until the documented order contract is frozen.
/// [productId] is the only identifier intended to cross the checkout boundary;
/// displayed prices are preview values and are never authoritative for checkout.
class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.description,
    required this.previewPrice,
    required this.quantity,
    required this.vegetarian,
  });

  final String productId;
  final String name;
  final String description;
  final int previewPrice;
  final int quantity;
  final bool vegetarian;

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        name: name,
        description: description,
        previewPrice: previewPrice,
        quantity: quantity ?? this.quantity,
        vegetarian: vegetarian,
      );
}

class CartSnapshot {
  const CartSnapshot(this.items);

  final List<CartItem> items;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get previewSubtotal =>
      items.fold(0, (sum, item) => sum + item.previewPrice * item.quantity);
}
