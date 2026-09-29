import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:snap_foodd/features/customer/data/order_models.dart';
import 'package:snap_foodd/features/customer/data/order_repository.dart';
import 'package:snap_foodd/features/customer/presentation/order_controller.dart';

void main() {
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

  final address = DeliveryAddress(
    label: 'Home',
    recipientName: 'Demo Customer',
    addressLine1: '10 Example Road',
    city: 'Mumbai',
    state: 'Maharashtra',
    postalCode: '400001',
    country: 'India',
  );

  test('checkout controller ignores duplicate submission while request is active', () async {
    final repository = FakeOrderRepository(createdOrder: order);
    final container = ProviderContainer(
      overrides: [
        orderRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(orderCheckoutControllerProvider.notifier);
    final request = CreateOrderRequest(
      items: const [OrderLineRequest(productId: '15', quantity: 1)],
      deliveryAddress: address,
    );

    final first = controller.submit(request);
    final second = controller.submit(request);
    final results = await Future.wait([first, second]);

    expect(results.whereType<Order>(), hasLength(1));
    expect(repository.lastCreateRequest?.items.single.productId, '15');
  });
}
