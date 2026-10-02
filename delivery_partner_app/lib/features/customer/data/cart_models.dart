/// A local cart line.
class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.description,
    required this.previewPrice,
    required this.quantity,
    required this.vegetarian,
    this.imageUrl,
  });

  final String productId;
  final String name;
  final String description;
  final int previewPrice;
  final int quantity;
  final bool vegetarian;
  final String? imageUrl;

  CartItem copyWith({int? quantity, String? imageUrl}) => CartItem(
    productId: productId,
    name: name,
    description: description,
    previewPrice: previewPrice,
    quantity: quantity ?? this.quantity,
    vegetarian: vegetarian,
    imageUrl: imageUrl ?? this.imageUrl,
  );
}

class CartSnapshot {
  const CartSnapshot(this.items);

  final List<CartItem> items;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get previewSubtotal => items.fold(
    0,
    (sum, item) => sum + item.previewPrice * item.quantity,
  );
}
