import 'package:flutter_test/flutter_test.dart';

import 'package:snap_foodd/features/delivery/data/delivery_models.dart';

void main() {
  test('decodes assignment ids and lifecycle status', () {
    final assignment = DeliveryAssignment.fromJson({
      'id': '42',
      'order_id': '1001',
      'status': 'OUT_FOR_DELIVERY',
      'pickup_address': 'Restaurant',
      'dropoff_address': 'Customer',
    });

    expect(assignment.id, 42);
    expect(assignment.orderId, 1001);
    expect(assignment.status, 'OUT_FOR_DELIVERY');
    expect(assignment.pickupAddress, 'Restaurant');
    expect(assignment.dropoffAddress, 'Customer');
  });

  test('serializes location update with UTC recorded timestamp', () {
    final update = DeliveryLocationUpdate(
      latitude: 19.076,
      longitude: 72.8777,
      recordedAt: DateTime.parse('2026-09-29T12:00:00Z'),
      accuracy: 8.5,
    );

    expect(update.toJson(), {
      'latitude': 19.076,
      'longitude': 72.8777,
      'recorded_at': '2026-09-29T12:00:00.000Z',
      'accuracy': 8.5,
    });
  });
}
