import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_transport.dart';
import '../../auth/data/session_store.dart';
import '../data/order_models.dart';
import '../data/order_repository.dart';

final orderApiTransportProvider = Provider<HttpApiTransport>((ref) {
  final transport = HttpApiTransport();
  ref.onDispose(transport.close);
  return transport;
});

final orderSessionStoreProvider = Provider<SessionStore>((ref) {
  return SecureSessionStore();
});

final orderApiClientProvider = Provider<ApiClient>((ref) {
  final sessionStore = ref.watch(orderSessionStoreProvider);
  return ApiClient(
    config: ApiConfig.fromEnvironment(),
    transport: ref.watch(orderApiTransportProvider),
    tokenProvider: sessionStore.readToken,
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return RemoteOrderRepository(ref.watch(orderApiClientProvider));
});

final orderCheckoutControllerProvider =
    AsyncNotifierProvider<OrderCheckoutController, OrderCheckoutState>(
  OrderCheckoutController.new,
);

class OrderCheckoutState {
  const OrderCheckoutState({
    this.isSubmitting = false,
    this.lastOrder,
  });

  final bool isSubmitting;
  final Order? lastOrder;
}

class OrderCheckoutController extends AsyncNotifier<OrderCheckoutState> {
  OrderRepository get _repository => ref.read(orderRepositoryProvider);

  @override
  Future<OrderCheckoutState> build() async => const OrderCheckoutState();

  Future<Order?> submit(CreateOrderRequest request) async {
    if (state.value?.isSubmitting == true) return null;

    state = AsyncData(
      const OrderCheckoutState(isSubmitting: true),
    );

    try {
      final order = await _repository.createOrder(request);
      state = AsyncData(OrderCheckoutState(lastOrder: order));
      return order;
    } on ApiException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }
}

final orderHistoryControllerProvider =
    AsyncNotifierProvider<OrderHistoryController, OrderHistoryState>(
  OrderHistoryController.new,
);

class OrderHistoryState {
  const OrderHistoryState({
    this.orders = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.selectedOrder,
  });

  final List<Order> orders;
  final int currentPage;
  final int lastPage;
  final int total;
  final Order? selectedOrder;

  bool get hasNextPage => currentPage < lastPage;
}

class OrderHistoryController extends AsyncNotifier<OrderHistoryState> {
  OrderRepository get _repository => ref.read(orderRepositoryProvider);

  @override
  Future<OrderHistoryState> build() async {
    final page = await _repository.fetchOrders();
    return _fromPage(page);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || !current.hasNextPage) return;

    final next = await _repository.fetchOrders(
      page: current.currentPage + 1,
    );
    state = AsyncData(
      OrderHistoryState(
        orders: [...current.orders, ...next.orders],
        currentPage: next.currentPage,
        lastPage: next.lastPage,
        total: next.total,
        selectedOrder: current.selectedOrder,
      ),
    );
  }

  Future<Order?> loadDetail(String orderId) async {
    try {
      final order = await _repository.fetchOrder(orderId);
      final current = state.value ?? const OrderHistoryState();
      state = AsyncData(
        OrderHistoryState(
          orders: current.orders,
          currentPage: current.currentPage,
          lastPage: current.lastPage,
          total: current.total,
          selectedOrder: order,
        ),
      );
      return order;
    } on ApiException {
      rethrow;
    }
  }

  OrderHistoryState _fromPage(OrderPage page) => OrderHistoryState(
        orders: page.orders,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        total: page.total,
      );
}
