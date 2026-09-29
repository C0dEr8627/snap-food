import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:snap_foodd/core/network/api_exception.dart';
import 'package:snap_foodd/features/customer/data/catalogue_models.dart';
import 'package:snap_foodd/features/customer/data/catalogue_repository.dart';
import 'package:snap_foodd/features/customer/presentation/catalogue_controller.dart';

void main() {
  test('loads categories and products into one snapshot', () async {
    final repository = FakeCatalogueRepository(
      categories: const [
        CatalogueRecord(payload: {'id': 'c1'}),
      ],
      products: const [
        CatalogueRecord(payload: {'id': 'p1'}),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        catalogueRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = await container.read(catalogueControllerProvider.future);

    expect(snapshot.categories.single.payload['id'], 'c1');
    expect(snapshot.products.single.payload['id'], 'p1');
  });

  test('exposes a safe retryable error when repository fails', () async {
    final repository = _FailingCatalogueRepository();

    final container = ProviderContainer(
      overrides: [
        catalogueRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(catalogueControllerProvider.future),
      throwsA(isA<ApiException>()),
    );

    final state = container.read(catalogueControllerProvider);
    expect(state.hasError, isTrue);
  });
}

class _FailingCatalogueRepository implements CatalogueRepository {
  @override
  Future<List<CatalogueRecord>> fetchCategories() async {
    throw const ApiException(
      message: 'Catalogue unavailable.',
      code: 'SERVER_ERROR',
      statusCode: 503,
    );
  }

  @override
  Future<List<CatalogueRecord>> fetchProducts({
    Map<String, String>? queryParameters,
  }) async {
    throw const ApiException(
      message: 'Catalogue unavailable.',
      code: 'SERVER_ERROR',
      statusCode: 503,
    );
  }

  @override
  Future<CatalogueRecord> fetchProduct(String productId) {
    throw const ApiException(
      message: 'Catalogue unavailable.',
      code: 'SERVER_ERROR',
      statusCode: 503,
    );
  }
}
