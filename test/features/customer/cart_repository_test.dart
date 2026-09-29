import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snap_foodd/features/customer/data/cart_repository.dart';
import 'package:snap_foodd/features/customer/presentation/cart_controller.dart';

void main() {
  test('local cart keeps product IDs and updates quantities', () {
    final repository = LocalCartRepository();

    expect(repository.load().items.map((item) => item.productId), [
      'biryani',
      'butter',
    ]);

    final updated = repository.setQuantity('biryani', 3);

    expect(updated.itemCount, 4);
    expect(
      updated.items.firstWhere((item) => item.productId == 'biryani').quantity,
      3,
    );
  });

  test('cart removes an item when quantity reaches zero', () {
    final repository = LocalCartRepository();

    final updated = repository.setQuantity('biryani', 0);

    expect(updated.items.map((item) => item.productId), ['butter']);
  });

  test('cart provider exposes preview subtotal from the repository', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final cart = container.read(cartControllerProvider);

    expect(cart.itemCount, 2);
    expect(cart.previewSubtotal, 600);
  });
}
