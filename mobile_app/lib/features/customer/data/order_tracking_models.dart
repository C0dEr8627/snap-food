class OrderTrackingLocation {
  const OrderTrackingLocation({
    required this.latitude,
    required this.longitude,
    this.recordedAt,
    this.accuracy,
  });

  final double latitude;
  final double longitude;
  final DateTime? recordedAt;
  final double? accuracy;

  factory OrderTrackingLocation.fromJson(Map<String, dynamic> json) {
    double? number(Object? value) => value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');
    return OrderTrackingLocation(
      latitude: number(json['latitude']) ?? 0,
      longitude: number(json['longitude']) ?? 0,
      recordedAt: DateTime.tryParse(json['recorded_at']?.toString() ?? ''),
      accuracy: number(json['accuracy']),
    );
  }
}

class OrderTrackingDestination {
  const OrderTrackingDestination({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory OrderTrackingDestination.fromJson(Map<String, dynamic> json) {
    double number(Object? value) => value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;

    return OrderTrackingDestination(
      latitude: number(json['latitude']),
      longitude: number(json['longitude']),
    );
  }
}

class DeliveryPartnerContact {
  const DeliveryPartnerContact({
    required this.name,
    this.phone,
    this.assignedAt,
  });

  final String name;
  final String? phone;
  final DateTime? assignedAt;

  factory DeliveryPartnerContact.fromJson(Map<String, dynamic> json) {
    final rawName = json['name']?.toString().trim();
    final rawPhone = json['phone']?.toString().trim();
    return DeliveryPartnerContact(
      name: rawName == null || rawName.isEmpty ? 'Delivery partner' : rawName,
      phone: rawPhone == null || rawPhone.isEmpty ? null : rawPhone,
      assignedAt: DateTime.tryParse(json['assigned_at']?.toString() ?? ''),
    );
  }
}

class OrderTracking {
  const OrderTracking({
    required this.status,
    required this.isStale,
    this.latestLocation,
    this.destination,
    this.deliveryPartner,
  });

  final String status;
  final bool isStale;
  final OrderTrackingLocation? latestLocation;
  final OrderTrackingDestination? destination;
  final DeliveryPartnerContact? deliveryPartner;

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    final rawLocation = json['latest_location'] ?? json['location'];
    final rawDestination = json['destination'];
    final rawPartner = json['delivery_partner'];
    return OrderTracking(
      status: json['status']?.toString() ?? '',
      isStale: json['is_stale'] == true,
      latestLocation: rawLocation is Map
          ? OrderTrackingLocation.fromJson(
              Map<String, dynamic>.from(rawLocation),
            )
          : null,
      destination: rawDestination is Map
          ? OrderTrackingDestination.fromJson(
              Map<String, dynamic>.from(rawDestination),
            )
          : null,
      deliveryPartner: rawPartner is Map
          ? DeliveryPartnerContact.fromJson(
              Map<String, dynamic>.from(rawPartner),
            )
          : null,
    );
  }
}
