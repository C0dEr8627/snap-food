import 'package:flutter_test/flutter_test.dart';
import 'package:snap_foodd/features/customer/data/order_models.dart';

void main() {
  test('parses admin cancellation reason from customer order payload', () {
    final order = Order.fromJson({
      'id': 42,
      'status': 'CANCELLED',
      'payment_method': 'COD',
      'payment_status': 'PENDING',
      'cancellation_reason': 'The requested item is no longer available.',
      'subtotal': '200.00',
      'delivery_fee': '40.00',
      'total': '240.00',
      'items': [],
    });

    expect(order.status, OrderStatus.cancelled);
    expect(
      order.cancellationReason,
      'The requested item is no longer available.',
    );
  });

  test('keeps cancellation reason optional for non-cancelled orders', () {
    final order = Order.fromJson({
      'id': 43,
      'status': 'ACCEPTED',
      'payment_method': 'COD',
      'payment_status': 'PENDING',
      'subtotal': '200.00',
      'delivery_fee': '40.00',
      'total': '240.00',
      'items': [],
    });

    expect(order.cancellationReason, isNull);
  });
}
