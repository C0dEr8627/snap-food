/// Transport-neutral catalogue record.
///
/// The current API contract does not define the successful JSON response shape,
/// so this model deliberately preserves the server payload instead of guessing
/// field names. A typed DTO can be introduced once the contract documents the
/// response fields.
class CatalogueRecord {
  const CatalogueRecord({required this.payload});

  final Map<String, dynamic> payload;

  factory CatalogueRecord.fromJson(Map<String, dynamic> json) =>
      CatalogueRecord(payload: Map<String, dynamic>.unmodifiable(json));
}

class CatalogueSnapshot {
  const CatalogueSnapshot({
    required this.categories,
    required this.products,
  });

  final List<CatalogueRecord> categories;
  final List<CatalogueRecord> products;
}
