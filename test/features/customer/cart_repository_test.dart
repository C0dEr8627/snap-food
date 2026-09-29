import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snap_foodd/features/customer/data/cart_models.dart';
import 'package:snap_foodd/features/customer/data/cart_repository.dart';
import 'package:snap_foodd/features/customer/presentation/cart_controller.dart';

CartItem _item(String id, {int quantity = 1}) => CartItem(
      productId: id,
      name: 'Product $id',
      description: 'Catalogue item',
      previewPrice: 100,
      quantity: quantity,
      vegetarian: false,
    );

void main() {
  test('cart starts empty so checkout cannot submit placeholder IDs', () {
    final repository = LocalCartRepository();
    expect(repository.load().items, isEmpty);
  });

  test('adding a catalogue product merges quantities and caps at 99', () {
    final repository = LocalCartRepository(
      initialItems: [_item('15', quantity: 98)],
    );

    final updated = repository.addItem(_item('15', quantity: 2));

    expect(updated.items.single.quantity, 99);
    expect(updated.items.single.productId, '15');
  });

  test('cart removes an item when quantity reaches zero', () {
    final repository = LocalCartRepository(initialItems: [_item('15')]);
    final updated = repository.setQuantity('15', 0);
    expect(updated.items, isEmpty);
  });

  test('controller exposes repository cart state', () {
    final container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(
          LocalCartRepository(initialItems: [_item('15')]),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(cartControllerProvider).items.single.productId,
      '15',
    );
  });
}
