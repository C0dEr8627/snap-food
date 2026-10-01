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
    final categories = <CatalogueCategory>[];
    for (final record in records) {
      try {
        categories.add(CatalogueCategory.fromJson(record));
      } on FormatException {
        // Ignore malformed optional category rows.
      }
    }
    return List.unmodifiable(categories);
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
    if (response is List) {
      final items = _decodeProducts(response);
      return CataloguePage(
        items: items,
        currentPage: 1,
        lastPage: 1,
        perPage: items.length,
        total: items.length,
      );
    }
    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'The server returned an unexpected products response.',
        code: 'INVALID_RESPONSE',
      );
    }
    final outerData = response['data'];
    // Accept either a Laravel paginator or a plain PHP collection response.
    final Object? rawPage = outerData is Map ? outerData : response;
    final page = rawPage is Map ? Map<String, dynamic>.from(rawPage) : <String, dynamic>{};
    final Object? rawRecords = outerData is List
        ? outerData
        : (page['data'] is List ? page['data'] : page['products']);
    if (rawRecords is! List) {
      throw const ApiException(
        message: 'The server returned an unexpected products page.',
        code: 'INVALID_RESPONSE',
      );
    }
    final records = rawRecords;
    try {
      return CataloguePage(
        items: _decodeProducts(records),
        currentPage: _pageInt(page['current_page'], 1),
        lastPage: _pageInt(page['last_page'], 1),
        perPage: _pageInt(page['per_page'], records.length),
        total: _pageInt(page['total'], records.length),
      );
    } on FormatException catch (error) {
      throw ApiException(message: error.message, code: 'INVALID_RESPONSE');
    }
  }

  List<CatalogueProduct> _decodeProducts(List records) {
    final products = <CatalogueProduct>[];
    for (final item in records) {
      if (item is! Map) continue;
      try {
        products.add(
          CatalogueProduct.fromJson(Map<String, dynamic>.from(item)),
        );
      } on FormatException {
        // One malformed row must not hide every valid product.
      }
    }
    return List.unmodifiable(products);
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
