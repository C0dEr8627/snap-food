import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'cart_models.dart';

abstract interface class CartRepository {
  Future<CartSnapshot> fetchCart();
  Future<CartSnapshot> setQuantity(String productId, int quantity);
  Future<CartSnapshot> clear();
}

class RemoteCartRepository implements CartRepository {
  const RemoteCartRepository(this._client);
  final ApiClient _client;

  @override
  Future<CartSnapshot> fetchCart() async => _decodeSnapshot(await _client.get('/consumer/cart'));

  @override
  Future<CartSnapshot> setQuantity(String productId, int quantity) async {
    if (productId.trim().isEmpty) throw const ApiException(message: 'A product id is required.', code: 'INVALID_PRODUCT_ID');
    if (quantity <= 0) {
      await _client.request('DELETE', '/consumer/cart/items/' + Uri.encodeComponent(productId));
    } else {
      await _client.request('PATCH', '/consumer/cart/items/' + Uri.encodeComponent(productId), body: {'quantity': quantity.clamp(1, 99)});
    }
    return fetchCart();
  }

  Future<CartSnapshot> addItem({required String productId, required int quantity}) async {
    await _client.post('/consumer/cart/items', body: {
      'product_id': int.tryParse(productId) ?? productId,
      'quantity': quantity.clamp(1, 99),
    });
    return fetchCart();
  }

  @override
  Future<CartSnapshot> clear() async {
    await _client.request('DELETE', '/consumer/cart');
    return const CartSnapshot([]);
  }

  CartSnapshot _decodeSnapshot(Object? response) {
    if (response is! Map<String, dynamic> || response['data'] is! List) {
      throw const ApiException(message: 'The server returned an unexpected cart response.', code: 'INVALID_RESPONSE');
    }
    return CartSnapshot((response['data'] as List).whereType<Map>().map((item) => CartItem.fromJson(Map<String, dynamic>.from(item))).toList(growable: false));
  }
}
