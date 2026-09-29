import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:snap_foodd/core/network/api_exception.dart';
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
      items: const [OrderLineRequest(productId: 15, quantity: 1)],
      deliveryAddress: address,
    );

    final first = controller.submit(request);
    final second = controller.submit(request);
    final results = await Future.wait([first, second]);

    expect(results.whereType<Order>(), hasLength(1));
    expect(repository.lastCreateRequest?.items.single.productId, '15');
  });

  test('checkout controller surfaces validation failures without retrying automatically', () async {
    final repository = _FailingOrderRepository(
      const ApiException(
        message: 'The selected product is unavailable.',
        code: 'VALIDATION_FAILED',
        statusCode: 422,
      ),
    );
    final container = ProviderContainer(
      overrides: [orderRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = await container.read(orderCheckoutControllerProvider.notifier).submit(
      CreateOrderRequest(items: const [OrderLineRequest(productId: 15, quantity: 1)], deliveryAddress: address),
    );

    expect(result, isNull);
    final state = container.read(orderCheckoutControllerProvider);
    expect(state.hasError, isTrue);
    expect((state.error as ApiException).code, 'VALIDATION_FAILED');
    expect(repository.calls, 1);
  });

  test('checkout controller surfaces HTTP 409 conflicts as recoverable errors', () async {
    final repository = _FailingOrderRepository(
      const ApiException(
        message: 'Order state changed. Please review your cart.',
        code: 'CONFLICT',
        statusCode: 409,
      ),
    );
    final container = ProviderContainer(
      overrides: [orderRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = await container.read(orderCheckoutControllerProvider.notifier).submit(
      CreateOrderRequest(items: const [OrderLineRequest(productId: 15, quantity: 1)], deliveryAddress: address),
    );

    expect(result, isNull);
    final state = container.read(orderCheckoutControllerProvider);
    expect(state.hasError, isTrue);
    expect((state.error as ApiException).statusCode, 409);
    expect((state.error as ApiException).code, 'CONFLICT');
    expect(repository.calls, 1);
  });
}

class _FailingOrderRepository implements OrderRepository {
  _FailingOrderRepository(this.error);
  final ApiException error;
  int calls = 0;

  @override
  Future<Order> createOrder(CreateOrderRequest request) async {
    calls++;
    throw error;
  }

  @override
  Future<OrderPage> fetchOrders({int? page, int? perPage}) async => const OrderPage(
    orders: [],
    currentPage: 1,
    lastPage: 1,
    total: 0,
  );

  @override
  Future<Order> fetchOrder(String orderId) async => throw error;
}
