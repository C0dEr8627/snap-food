import 'package:flutter_test/flutter_test.dart';

import 'package:snap_foodd/features/customer/data/catalogue_models.dart';

void main() {
  test('maps documented product fields without recalculating money', () {
    final product = CatalogueProduct.fromJson({
      'id': 15,
      'category_id': 2,
      'name': 'Chicken Biryani',
      'price': '320.00',
      'is_active': true,
      'is_available': true,
      'category': {'id': 2, 'name': 'Biryani'},
    });

    expect(product.id, 15);
    expect(product.categoryId, 2);
    expect(product.name, 'Chicken Biryani');
    expect(product.price, '320.00');
    expect(product.category?.name, 'Biryani');
  });

  test('rejects missing required product fields', () {
    expect(
      () => CatalogueProduct.fromJson({'id': 15}),
      throwsA(isA<FormatException>()),
    );
  });

  test('exposes pagination metadata', () {
    final page = CataloguePage(
      items: const [],
      currentPage: 1,
      lastPage: 3,
      perPage: 20,
      total: 55,
    );
    expect(page.hasNextPage, isTrue);
  });
}
