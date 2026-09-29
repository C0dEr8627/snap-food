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

class OrderTracking {
  const OrderTracking({
    required this.status,
    required this.isStale,
    this.latestLocation,
  });

  final String status;
  final bool isStale;
  final OrderTrackingLocation? latestLocation;

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    final rawLocation = json['latest_location'] ?? json['location'];
    return OrderTracking(
      status: json['status']?.toString() ?? '',
      isStale: json['is_stale'] == true,
      latestLocation: rawLocation is Map
          ? OrderTrackingLocation.fromJson(
              Map<String, dynamic>.from(rawLocation),
            )
          : null,
    );
  }
}
