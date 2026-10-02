class CartItem {
  const CartItem({required this.productId, required this.name, required this.description, required this.previewPrice, required this.quantity, required this.vegetarian, this.imageUrl});
  final String productId;
  final String name;
  final String description;
  final int previewPrice;
  final int quantity;
  final bool vegetarian;
  final String? imageUrl;

  CartItem copyWith({int? quantity, String? imageUrl}) => CartItem(
    productId: productId, name: name, description: description, previewPrice: previewPrice,
    quantity: quantity ?? this.quantity, vegetarian: vegetarian, imageUrl: imageUrl ?? this.imageUrl,
  );

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productId: json['product_id'].toString(),
    name: (json['name'] ?? '').toString(),
    description: (json['description'] ?? 'Catalogue item').toString(),
    previewPrice: json['preview_price'] is num ? (json['preview_price'] as num).toInt() : int.tryParse((json['preview_price'] ?? 0).toString()) ?? 0,
    quantity: json['quantity'] is num ? (json['quantity'] as num).toInt() : int.tryParse((json['quantity'] ?? 1).toString()) ?? 1,
    vegetarian: json['vegetarian'] == true,
    imageUrl: json['image_url']?.toString(),
  );
}

class CartSnapshot {
  const CartSnapshot(this.items);
  final List<CartItem> items;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get previewSubtotal => items.fold(0, (sum, item) => sum + item.previewPrice * item.quantity);
}
