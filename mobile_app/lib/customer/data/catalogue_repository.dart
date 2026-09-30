import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'catalogue_models.dart';

abstract interface class CatalogueRepository {
  Future<List<CatalogueCategory>> fetchCategories();
  Future<CataloguePage> fetchProducts({Map<String, String>? queryParameters});
  Future<CatalogueProduct> fetchProduct(String productId);
}

class RemoteCatalogueRepository implements CatalogueRepository {
  const RemoteCatalogueRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<CatalogueCategory>> fetchCategories() async {
    final response = await _client.get('/consumer/categories');
    final records = _decodeCollection(response, resource: 'categories');
    try {
      return records.map(CatalogueCategory.fromJson).toList(growable: false);
    } on FormatException catch (error) {
      throw ApiException(message: error.message, code: 'INVALID_RESPONSE');
    }
  }

  @override
  Future<CataloguePage> fetchProducts({
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.get(
      '/consumer/products',
      queryParameters: queryParameters,
    );
    return _decodeProductPage(response);
  }

  @override
  Future<CatalogueProduct> fetchProduct(String productId) async {
    final normalized = productId.trim();
    final parsedId = int.tryParse(normalized);
    if (parsedId == null || parsedId <= 0) {
      throw const ApiException(
        message: 'A valid numeric product id is required.',
        code: 'INVALID_PRODUCT_ID',
      );
    }
    final response = await _client.get(
      '/consumer/products/${Uri.encodeComponent(normalized)}',
    );
    final payload = _decodeSingle(response, resource: 'product');
    try {
      return CatalogueProduct.fromJson(payload);
    } on FormatException catch (error) {
      throw ApiException(message: error.message, code: 'INVALID_RESPONSE');
    }
  }

  List<Map<String, dynamic>> _decodeCollection(
    Object? response, {
    required String resource,
  }) {
    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
      final value = response[resource];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
    }
    throw ApiException(
      message: 'The server returned an unexpected $resource response.',
      code: 'INVALID_RESPONSE',
    );
  }

  CataloguePage _decodeProductPage(Object? response) {
    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'The server returned an unexpected products response.',
        code: 'INVALID_RESPONSE',
      );
    }
    final outerData = response['data'];
    if (outerData is! Map) {
      throw const ApiException(
        message: 'The server returned an unexpected products response.',
        code: 'INVALID_RESPONSE',
      );
    }
    final page = Map<String, dynamic>.from(outerData);
    final records = page['data'];
    if (records is! List) {
      throw const ApiException(
        message: 'The server returned an unexpected products page.',
        code: 'INVALID_RESPONSE',
      );
    }
    try {
      return CataloguePage(
        items: records
            .whereType<Map>()
            .map(
              (item) =>
                  CatalogueProduct.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false),
        currentPage: _pageInt(page['current_page'], 1),
        lastPage: _pageInt(page['last_page'], 1),
        perPage: _pageInt(page['per_page'], records.length),
        total: _pageInt(page['total'], records.length),
      );
    } on FormatException catch (error) {
      throw ApiException(message: error.message, code: 'INVALID_RESPONSE');
    }
  }

  Map<String, dynamic> _decodeSingle(
    Object? response, {
    required String resource,
  }) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map) return Map<String, dynamic>.from(data);
      return response;
    }
    throw ApiException(
      message: 'The server returned an unexpected $resource response.',
      code: 'INVALID_RESPONSE',
    );
  }

  int _pageInt(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class FakeCatalogueRepository implements CatalogueRepository {
  FakeCatalogueRepository({
    Iterable<CatalogueCategory> categories = const [],
    Iterable<CatalogueProduct> products = const [],
  }) : _categories = List.unmodifiable(categories),
       _products = List.unmodifiable(products);

  final List<CatalogueCategory> _categories;
  final List<CatalogueProduct> _products;

  @override
  Future<List<CatalogueCategory>> fetchCategories() async => _categories;

  @override
  Future<CataloguePage> fetchProducts({
    Map<String, String>? queryParameters,
  }) async {
    return CataloguePage(
      items: _products,
      currentPage: 1,
      lastPage: 1,
      perPage: _products.length,
      total: _products.length,
    );
  }

  @override
  Future<CatalogueProduct> fetchProduct(String productId) async {
    final id = int.tryParse(productId);
    for (final product in _products) {
      if (product.id == id) return product;
    }
    throw const ApiException(
      message: 'Product not found in the local catalogue.',
      code: 'NOT_FOUND',
      statusCode: 404,
    );
  }
}
