import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:snap_foodd/core/network/api_exception.dart';
import 'package:snap_foodd/features/customer/data/catalogue_models.dart';
import 'package:snap_foodd/features/customer/data/catalogue_repository.dart';
import 'package:snap_foodd/features/customer/presentation/catalogue_controller.dart';

void main() {
  test('loads typed categories and paginated products', () async {
    final repository = FakeCatalogueRepository(
      categories: const [CatalogueCategory(id: 2, name: 'Biryani')],
      products: const [
        CatalogueProduct(
          id: 15,
          categoryId: 2,
          name: 'Chicken Biryani',
          price: '320.00',
          isActive: true,
          isAvailable: true,
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [catalogueRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final snapshot = await container.read(catalogueControllerProvider.future);

    expect(snapshot.categories.single.id, 2);
    expect(snapshot.products.items.single.id, 15);
    expect(snapshot.products.hasNextPage, isFalse);
  });

  test('exposes a safe retryable error when repository fails', () async {
    final repository = _FailingCatalogueRepository();

    final container = ProviderContainer(
      overrides: [catalogueRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final errorCompleter = Completer<Object?>();
    final subscription = container.listen<AsyncValue<CatalogueSnapshot>>(
      catalogueControllerProvider,
      (_, next) {
        if (next.hasError && !errorCompleter.isCompleted) {
          errorCompleter.complete(next.error);
        }
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final error = await errorCompleter.future.timeout(const Duration(seconds: 5));
    expect(error, isA<ApiException>());
    expect(container.read(catalogueControllerProvider).hasError, isTrue);
  });
}

class _FailingCatalogueRepository implements CatalogueRepository {
  @override
  Future<List<CatalogueCategory>> fetchCategories() async {
    throw const ApiException(
      message: 'Catalogue unavailable.',
      code: 'SERVER_ERROR',
      statusCode: 503,
    );
  }

  @override
  Future<CataloguePage> fetchProducts({
    Map<String, String>? queryParameters,
  }) async {
    throw const ApiException(
      message: 'Catalogue unavailable.',
      code: 'SERVER_ERROR',
      statusCode: 503,
    );
  }

  @override
  Future<CatalogueProduct> fetchProduct(String productId) {
    throw const ApiException(
      message: 'Catalogue unavailable.',
      code: 'SERVER_ERROR',
      statusCode: 503,
    );
  }
}
