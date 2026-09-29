class DeliveryAssignment {
  const DeliveryAssignment({
    required this.id,
    this.orderId,
    this.status = '',
    this.pickupAddress,
    this.dropoffAddress,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int? orderId;
  final String status;
  final String? pickupAddress;
  final String? dropoffAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory DeliveryAssignment.fromJson(Map<String, dynamic> json) {
    int? integer(Object? value) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
    return DeliveryAssignment(
      id: integer(json['id']) ?? 0,
      orderId: integer(json['order_id']),
      status: json['status']?.toString() ?? '',
      pickupAddress: json['pickup_address']?.toString() ?? json['restaurant_address']?.toString(),
      dropoffAddress: json['dropoff_address']?.toString() ?? json['customer_address']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class DeliveryAssignmentPage {
  const DeliveryAssignmentPage({required this.items, this.currentPage = 1, this.lastPage = 1});
  final List<DeliveryAssignment> items;
  final int currentPage;
  final int lastPage;

  factory DeliveryAssignmentPage.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final items = raw is List
        ? raw.whereType<Map>().map((item) => DeliveryAssignment.fromJson(Map<String, dynamic>.from(item))).toList()
        : <DeliveryAssignment>[];
    int integer(Object? value, int fallback) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? fallback;
    return DeliveryAssignmentPage(
      items: items,
      currentPage: integer(json['current_page'], 1),
      lastPage: integer(json['last_page'], 1),
    );
  }
}

class DeliveryLocationUpdate {
  const DeliveryLocationUpdate({required this.latitude, required this.longitude, required this.recordedAt, this.accuracy});
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double? accuracy;

  Map<String, Object?> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'recorded_at': recordedAt.toUtc().toIso8601String(),
    if (accuracy != null) 'accuracy': accuracy,
  };
}
