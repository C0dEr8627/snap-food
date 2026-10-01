class CatalogueCategory {
  const CatalogueCategory({required this.id, required this.name});
  final int id;
  final String name;
  factory CatalogueCategory.fromJson(Map<String, dynamic> json) =>
      CatalogueCategory(
        id: _requiredInt(json['id'], 'category.id'),
        name: _requiredString(json['name'], 'category.name'),
      );
}

class CatalogueProduct {
  const CatalogueProduct({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.isActive,
    required this.isAvailable,
    this.category,
    this.imageUrl,
  });
  final int id;
  final int categoryId;
  final String name;
  final String price;
  final bool isActive;
  final bool isAvailable;
  final CatalogueCategory? category;
  final String? imageUrl;

  factory CatalogueProduct.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];
    return CatalogueProduct(
      id: _requiredInt(json['id'], 'product.id'),
      categoryId: _optionalInt(json['category_id'] ?? json['categoryId']) ?? 0,
      name: _requiredString(json['name'] ?? json['title'], 'product.name'),
      price: _requiredString(
        json['price'] ?? json['selling_price'] ?? json['amount'],
        'product.price',
      ),
      isActive: _optionalBool(json['is_active'] ?? json['isActive']) ?? true,
      isAvailable: _optionalBool(
            json['is_available'] ?? json['isAvailable'] ?? json['available'],
          ) ??
          true,
      category: _decodeCategory(categoryJson),
      imageUrl: _optionalString(
        json['image_url'] ??
            json['imageUrl'] ??
            json['image'] ??
            json['photo_url'] ??
            json['photo'],
      ),
    );
  }
}

class CataloguePage {
  const CataloguePage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });
  final List<CatalogueProduct> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  bool get hasNextPage => currentPage < lastPage;
}

class CatalogueSnapshot {
  const CatalogueSnapshot({required this.categories, required this.products});
  final List<CatalogueCategory> categories;
  final CataloguePage products;
}

int _requiredInt(Object? value, String field) {
  final parsed = _optionalInt(value);
  if (parsed != null) return parsed;
  throw FormatException('Missing or invalid $field.');
}

int? _optionalInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String _requiredString(Object? value, String field) {
  final text = _optionalString(value);
  if (text != null) return text;
  throw FormatException('Missing or invalid $field.');
}

String? _optionalString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

bool _requiredBool(Object? value, String field) {
  final parsed = _optionalBool(value);
  if (parsed != null) return parsed;
  throw FormatException('Missing or invalid $field.');
}

bool? _optionalBool(Object? value) {
  if (value is bool) return value;
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == '1' || normalized == 'true' || normalized == 'yes') return true;
  if (normalized == '0' || normalized == 'false' || normalized == 'no') return false;
  return null;
}

CatalogueCategory? _decodeCategory(Object? value) {
  if (value is! Map) return null;
  try {
    return CatalogueCategory.fromJson(Map<String, dynamic>.from(value));
  } on FormatException {
    return null;
  }
}
