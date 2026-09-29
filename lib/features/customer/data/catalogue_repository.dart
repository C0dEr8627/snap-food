import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'catalogue_models.dart';

abstract interface class CatalogueRepository {
  Future<List<CatalogueRecord>> fetchCategories();

  Future<List<CatalogueRecord>> fetchProducts({
    Map<String, String>? queryParameters,
  });

  Future<CatalogueRecord> fetchProduct(String productId);
}

/// Remote implementation backed exclusively by the documented catalogue
/// endpoints. Response parsing stays conservative until API_CONTRACT.md
/// documents the successful response envelope and product/category fields.
class RemoteCatalogueRepository implements CatalogueRepository {
  const RemoteCatalogueRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<CatalogueRecord>> fetchCategories() async {
    final response = await _client.get('/categories');
    return _decodeCollection(response, resource: 'categories');
  }

  @override
  Future<List<CatalogueRecord>> fetchProducts({
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.get(
      '/products',
      queryParameters: queryParameters,
    );
    return _decodeCollection(response, resource: 'products');
  }

  @override
  Future<CatalogueRecord> fetchProduct(String productId) async {
    if (productId.trim().isEmpty) {
      throw const ApiException(
        message: 'A product id is required.',
        code: 'INVALID_PRODUCT_ID',
      );
    }

    final response = await _client.get('/products/${Uri.encodeComponent(productId)}');
    if (response is Map<String, dynamic>) {
      return CatalogueRecord.fromJson(response);
    }
    throw const ApiException(
      message: 'The server returned an unexpected product response.',
      code: 'INVALID_RESPONSE',
    );
  }

  List<CatalogueRecord> _decodeCollection(
    Object? response, {
    required String resource,
  }) {
    if (response is List) {
      return response
          .whereType<Map>()
          .map(
            (item) => CatalogueRecord.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false);
    }

    if (response is Map<String, dynamic>) {
      // Do not assume a common response envelope. Accept only an explicitly
      // named resource key if the backend returns one.
      final value = response[resource];
      if (value is List) {
        return value
            .whereType<Map>()
            .map(
              (item) => CatalogueRecord.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false);
      }
    }

    throw ApiException(
      message: 'The server returned an unexpected $resource response.',
      code: 'INVALID_RESPONSE',
    );
  }
}

/// Deterministic local repository for controller/widget tests and offline
/// development. It intentionally accepts fixture records supplied by tests.
class FakeCatalogueRepository implements CatalogueRepository {
  FakeCatalogueRepository({
    Iterable<CatalogueRecord> categories = const [],
    Iterable<CatalogueRecord> products = const [],
  })  : _categories = List.unmodifiable(categories),
        _products = List.unmodifiable(products);

  final List<CatalogueRecord> _categories;
  final List<CatalogueRecord> _products;

  @override
  Future<List<CatalogueRecord>> fetchCategories() async => _categories;

  @override
  Future<List<CatalogueRecord>> fetchProducts({
    Map<String, String>? queryParameters,
  }) async => _products;

  @override
  Future<CatalogueRecord> fetchProduct(String productId) async {
    for (final product in _products) {
      final id = product.payload['id'];
      if (id != null && id.toString() == productId) return product;
    }
    throw const ApiException(
      message: 'Product not found in the local catalogue.',
      code: 'NOT_FOUND',
      statusCode: 404,
    );
  }
}
