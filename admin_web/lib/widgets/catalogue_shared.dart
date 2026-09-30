part of '../main.dart';

class _CatalogueProduct {
  _CatalogueProduct({this.id, required this.name, required this.slug, required this.description, required this.categoryId, required this.categoryName, required this.price, required this.stock, required this.available, required this.active, this.image, this.dietary = 'Non-Veg', this.gst = '5%', this.prepTime = 15, this.tags = const []});
  int? id;
  String name, slug, description, categoryName;
  int? categoryId;
  double price;
  int stock, prepTime;
  bool available, active;
  String? image;
  String dietary, gst;
  List<String> tags;
  bool get outOfStock => stock <= 0 || !available;
  bool get lowStock => stock > 0 && stock <= 5;
  String get badge {
    if (outOfStock) return 'Sold Out';
    if (lowStock) return stock.toString() + ' Left';
    if (tags.any((e) => e.toLowerCase() == 'bestseller')) return 'Bestseller';
    if (tags.any((e) => e.toLowerCase() == 'seasonal')) return 'Seasonal';
    return '';
  }
  factory _CatalogueProduct.fromJson(Map<String, dynamic> j) {
    final c = j['category'];
    return _CatalogueProduct(
      id: _asInt(j['id']), name: j['name']?.toString() ?? '', slug: j['slug']?.toString() ?? '',
      description: j['description']?.toString() ?? '', categoryId: _asInt(j['category_id']),
      categoryName: c is Map ? c['name']?.toString() ?? '' : '', price: _asDouble(j['price']),
      stock: _asInt(j['stock_quantity']) ?? 0, available: j['is_available'] != false,
      active: j['is_active'] != false, image: j['image']?.toString(),
    );
  }
  Map<String, dynamic> toApiJson() => {
    'category_id': categoryId, 'name': name.trim(), 'slug': slug.trim(),
    'description': description.trim().isEmpty ? null : description.trim(),
    'price': price.toStringAsFixed(2), 'image': image, 'stock_quantity': stock,
    'is_available': available, 'is_active': active,
  };
}

class _CatalogueCategory {
  const _CatalogueCategory({this.id, required this.name, this.slug = '', this.sortOrder = 0, this.active = true, this.count = 0});
  final int? id;
  final String name, slug;
  final int sortOrder, count;
  final bool active;
  factory _CatalogueCategory.fromJson(Map<String, dynamic> j) => _CatalogueCategory(
    id: _asInt(j['id']), name: j['name']?.toString() ?? '', slug: j['slug']?.toString() ?? '',
    sortOrder: _asInt(j['sort_order']) ?? 0, active: j['is_active'] != false,
    count: _asInt(j['products_count']) ?? 0,
  );
}

int? _asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '');
double _asDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

class _CatalogueResponse {
  const _CatalogueResponse({this.products = const [], this.currentPage = 1, this.lastPage = 1, this.total = 0});
  final List<_CatalogueProduct> products;
  final int currentPage, lastPage, total;
}

class _CatalogueApiException implements Exception {
  const _CatalogueApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override String toString() => message;
}

class _CatalogueRepository {
  _CatalogueRepository({this.baseUrl = apiBaseUrl});
  final String baseUrl;
  String get _root {
    final v = baseUrl.trim();
    if (v.isEmpty) return '';
    return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
  }
  String get _token => html.window.localStorage['snap_foodd_admin_token'] ?? '';
  bool get liveEnabled => _root.isNotEmpty && _token.isNotEmpty;
  Map<String, String> get _headers => {
    'Accept': 'application/json', 'Content-Type': 'application/json',
    if (_token.isNotEmpty) 'Authorization': 'Bearer ' + _token,
  };
  Uri _uri(String path, [Map<String, String>? query]) {
    final url = _root.endsWith('/api/v1') ? _root + path : _root + '/api/v1' + path;
    return Uri.parse(url).replace(queryParameters: query);
  }
  Future<_CatalogueResponse> products({String search = '', int? categoryId, int page = 1, int perPage = 15}) async {
    if (!liveEnabled) return const _CatalogueResponse();
    final q = <String, String>{'page': page.toString(), 'per_page': perPage.toString()};
    if (search.trim().isNotEmpty) q['search'] = search.trim();
    if (categoryId != null) q['category_id'] = categoryId.toString();
    final res = await http.get(_uri('/admin/products', q), headers: _headers);
    if (res.statusCode < 200 || res.statusCode >= 300) throw _CatalogueApiException(res.statusCode, _message(res));
    final root = jsonDecode(res.body);
    final p = root is Map ? root['data'] : null;
    final rows = p is Map && p['data'] is List ? p['data'] as List : const [];
    return _CatalogueResponse(
      products: rows.whereType<Map>().map((e) => _CatalogueProduct.fromJson(Map<String, dynamic>.from(e))).toList(),
      currentPage: _asInt(p is Map ? p['current_page'] : null) ?? page,
      lastPage: _asInt(p is Map ? p['last_page'] : null) ?? page,
      total: _asInt(p is Map ? p['total'] : null) ?? rows.length,
    );
  }
  Future<List<_CatalogueCategory>> categories() async {
    if (!liveEnabled) return const [];
    final res = await http.get(_uri('/admin/categories', {'per_page': '100'}), headers: _headers);
    if (res.statusCode < 200 || res.statusCode >= 300) throw _CatalogueApiException(res.statusCode, _message(res));
    final root = jsonDecode(res.body);
    final p = root is Map ? root['data'] : null;
    final rows = p is Map && p['data'] is List ? p['data'] as List : const [];
    return rows.whereType<Map>().map((e) => _CatalogueCategory.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  Future<_CatalogueProduct> save(_CatalogueProduct product) async {
    if (!liveEnabled) return product;
    final create = product.id == null;
    final path = create ? '/admin/products' : '/admin/products/' + product.id.toString();
    final res = create
      ? await http.post(_uri(path), headers: _headers, body: jsonEncode(product.toApiJson()))
      : await http.patch(_uri(path), headers: _headers, body: jsonEncode(product.toApiJson()));
    if (res.statusCode < 200 || res.statusCode >= 300) throw _CatalogueApiException(res.statusCode, _message(res));
    final root = jsonDecode(res.body);
    final data = root is Map && root['data'] is Map ? Map<String, dynamic>.from(root['data']) : <String, dynamic>{};
    return _CatalogueProduct.fromJson(data);
  }
  Future<void> deactivate(_CatalogueProduct product) async {
    if (!liveEnabled || product.id == null) return;
    final res = await http.delete(_uri('/admin/products/' + product.id.toString()), headers: _headers);
    if (res.statusCode < 200 || res.statusCode >= 300) throw _CatalogueApiException(res.statusCode, _message(res));
  }
  Future<_CatalogueCategory> saveCategory({int? id, required String name, required String slug, required int sortOrder, required bool active}) async {
    if (!liveEnabled) return _CatalogueCategory(id: id, name: name, slug: slug, sortOrder: sortOrder, active: active);
    final body = jsonEncode({'name': name.trim(), 'slug': slug.trim(), 'sort_order': sortOrder, 'is_active': active});
    final res = id == null ? await http.post(_uri('/admin/categories'), headers: _headers, body: body) : await http.patch(_uri('/admin/categories/' + id.toString()), headers: _headers, body: body);
    if (res.statusCode < 200 || res.statusCode >= 300) throw _CatalogueApiException(res.statusCode, _message(res));
    final root = jsonDecode(res.body);
    final data = root is Map && root['data'] is Map ? Map<String, dynamic>.from(root['data']) : <String, dynamic>{};
    return _CatalogueCategory.fromJson(data);
  }
  Future<void> deleteCategory(int id) async {
    if (!liveEnabled) return;
    final res = await http.delete(_uri('/admin/categories/' + id.toString()), headers: _headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _CatalogueApiException(res.statusCode, _message(res));
    }
  }

  static String _message(http.Response res) {
    try { final v = jsonDecode(res.body); if (v is Map && v['message'] != null) return v['message'].toString(); } catch (_) {}
    return 'Catalogue API request failed (' + res.statusCode.toString() + ').';
  }
}

const _previewCatalogueCategories = <_CatalogueCategory>[
  _CatalogueCategory(id: 1, name: 'Biryani & Bowls', count: 22),
  _CatalogueCategory(id: 2, name: 'Burgers & Wraps', count: 18),
  _CatalogueCategory(id: 3, name: 'Mumbai Street Specials', count: 14),
  _CatalogueCategory(id: 4, name: 'Beverages & Shakes', count: 19),
  _CatalogueCategory(id: 5, name: 'Desserts', count: 7),
  _CatalogueCategory(id: 6, name: 'Sides & Munchies', count: 6),
];

final _previewCatalogueProducts = <_CatalogueProduct>[
  _CatalogueProduct(name: 'Special Murgh Dum Biryani Handi', slug: 'special-murgh-dum-biryani-handi', description: 'Slow-cooked fragrant basmati rice with marinated chicken and whole spices.', categoryId: 1, categoryName: 'Biryani & Bowls', price: 320, stock: 18, available: true, active: true, prepTime: 25, tags: ['Bestseller']),
  _CatalogueProduct(name: 'The Truffle Beast Burger', slug: 'the-truffle-beast-burger', description: 'Double smash patty, melted sharp cheddar and black truffle aioli.', categoryId: 2, categoryName: 'Burgers & Wraps', price: 390, stock: 12, available: true, active: true, prepTime: 18),
  _CatalogueProduct(name: 'Bombay Masala Toastie', slug: 'bombay-masala-toastie', description: 'Spiced potato mash, peppers, Amul butter and green mint chutney.', categoryId: 3, categoryName: 'Mumbai Street Specials', price: 170, stock: 4, available: true, active: true, dietary: 'Pure Veg', prepTime: 12),
  _CatalogueProduct(name: 'Alphonso Mango Pure Shake', slug: 'alphonso-mango-pure-shake', description: 'Ratnagiri mango pulp, full-cream milk and crushed ice.', categoryId: 4, categoryName: 'Beverages & Shakes', price: 220, stock: 25, available: true, active: true, dietary: 'Pure Veg', prepTime: 8, tags: ['Seasonal']),
  _CatalogueProduct(name: 'Peri Peri Crisp Fries', slug: 'peri-peri-crisp-fries', description: 'Golden crisp potato wedges seasoned with African bird pepper and herbs.', categoryId: 6, categoryName: 'Sides & Munchies', price: 145, stock: 0, available: false, active: true, dietary: 'Pure Veg', prepTime: 10),
  _CatalogueProduct(name: 'Charcoal Chicken Tikka Roll', slug: 'charcoal-chicken-tikka-roll', description: 'Charcoal roasted chicken tikka, spiced onions and mint yogurt in flaky paratha.', categoryId: 2, categoryName: 'Burgers & Wraps', price: 260, stock: 9, available: true, active: true, prepTime: 16),
  _CatalogueProduct(name: 'Paneer Tikka Rice Bowl', slug: 'paneer-tikka-rice-bowl', description: 'Smoky paneer, fragrant rice, fresh greens and house dressing.', categoryId: 1, categoryName: 'Biryani & Bowls', price: 240, stock: 7, available: true, active: true, dietary: 'Pure Veg', prepTime: 15),
  _CatalogueProduct(name: 'Classic Masala Chai', slug: 'classic-masala-chai', description: 'Slow-brewed black tea with ginger, cardamom and warming spices.', categoryId: 4, categoryName: 'Beverages & Shakes', price: 90, stock: 30, available: true, active: true, dietary: 'Pure Veg', prepTime: 7),
];
