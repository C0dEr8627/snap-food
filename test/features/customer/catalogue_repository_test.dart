import 'package:flutter_test/flutter_test.dart';

import 'package:snap_foodd/features/customer/data/catalogue_models.dart';
import 'package:snap_foodd/features/customer/data/catalogue_repository.dart';

void main() {
  group('FakeCatalogueRepository', () {
    test('returns supplied category and product fixtures', () async {
      final repository = FakeCatalogueRepository(
        categories: const [
          CatalogueRecord(payload: {'fixture': 'category'}),
        ],
        products: const [
          CatalogueRecord(payload: {'id': 'p1', 'fixture': 'product'}),
        ],
      );

      expect(
        (await repository.fetchCategories()).single.payload['fixture'],
        'category',
      );
      expect(
        (await repository.fetchProducts()).single.payload['id'],
        'p1',
      );
    });

    test('finds a product by fixture id', () async {
      final repository = FakeCatalogueRepository(
        products: const [
          CatalogueRecord(payload: {'id': 'p1'}),
        ],
      );

      expect((await repository.fetchProduct('p1')).payload['id'], 'p1');
    });

    test('reports a missing fixture product as not found', () async {
      final repository = FakeCatalogueRepository();

      expect(
        () => repository.fetchProduct('missing'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
