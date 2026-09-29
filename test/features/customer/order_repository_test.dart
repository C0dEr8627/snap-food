import 'package:flutter_test/flutter_test.dart';

import 'package:snap_foodd/features/customer/data/order_models.dart';
import 'package:snap_foodd/features/customer/data/order_repository.dart';

void main() {
  final address = DeliveryAddress(
    label: 'Home',
    recipientName: 'Demo Customer',
    addressLine1: '10 Example Road',
    city: 'Mumbai',
    state: 'Maharashtra',
    postalCode: '400001',
    country: 'India',
  );

  test('serializes COD checkout with product ids, quantities and address', () {
    final request = CreateOrderRequest(
      items: const [
        OrderLineRequest(productId: '15', quantity: 2),
      ],
      deliveryAddress: address,
    );

    final json = request.toJson();

    expect(json['payment_method'], 'COD');
    expect((json['items'] as List).single['product_id'], '15');
    expect((json['items'] as List).single['quantity'], 2);
    expect((json['delivery_address'] as Map)['postal_code'], '400001');
  });

  test('stores the checkout request and returns the server order fixture', () async {
    const order = Order(
      id: '1001',
      status: OrderStatus.placed,
      paymentMethod: 'COD',
      paymentStatus: 'PENDING',
      subtotal: '640.00',
      deliveryFee: '40.00',
      total: '680.00',
      items: [],
      deliveryAddress: null,
      payload: {},
    );

    final repository = FakeOrderRepository(
      orders: const [order],
      createdOrder: order,
    );

    final created = await repository.createOrder(
      CreateOrderRequest(items: const [], deliveryAddress: address),
    );

    expect(created.id, '1001');
    expect(created.total, '680.00');
    expect(repository.lastCreateRequest?.items, isEmpty);
  });

  test('reports a missing order fixture as not found', () async {
    final repository = FakeOrderRepository();

    expect(
      () => repository.fetchOrder('missing'),
      throwsA(isA<Exception>()),
    );
  });
}
