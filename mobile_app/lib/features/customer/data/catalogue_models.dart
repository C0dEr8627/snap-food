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
  });
  final int id;
  final int categoryId;
  final String name;
  final String price;
  final bool isActive;
  final bool isAvailable;
  final CatalogueCategory? category;

  factory CatalogueProduct.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];
    return CatalogueProduct(
      id: _requiredInt(json['id'], 'product.id'),
      categoryId: _requiredInt(json['category_id'], 'product.category_id'),
      name: _requiredString(json['name'], 'product.name'),
      price: _requiredString(json['price'], 'product.price'),
      isActive: _requiredBool(json['is_active'], 'product.is_active'),
      isAvailable: _requiredBool(json['is_available'], 'product.is_available'),
      category: categoryJson is Map
          ? CatalogueCategory.fromJson(Map<String, dynamic>.from(categoryJson))
          : null,
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
  if (value is int) return value;
  if (value is num) return value.toInt();
  final parsed = int.tryParse(value?.toString() ?? '');
  if (parsed != null) return parsed;
  throw FormatException('Missing or invalid $field.');
}

String _requiredString(Object? value, String field) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty)
    throw FormatException('Missing or invalid $field.');
  return text;
}

bool _requiredBool(Object? value, String field) {
  if (value is bool) return value;
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == '1' || normalized == 'true' || normalized == 'yes') {
    return true;
  }
  if (normalized == '0' || normalized == 'false' || normalized == 'no') {
    return false;
  }
  throw FormatException('Missing or invalid $field.');
}
