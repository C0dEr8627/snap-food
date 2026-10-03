import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_transport.dart';
import '../../auth/data/session_store.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/order_models.dart';
import '../data/order_repository.dart';
import '../data/order_tracking_models.dart';

final orderApiTransportProvider = Provider<HttpApiTransport>((ref) {
  final transport = HttpApiTransport();
  ref.onDispose(transport.close);
  return transport;
});

final orderSessionStoreProvider = Provider<SessionStore>((ref) {
  return SecureSessionStore();
});

final orderApiClientProvider = Provider<ApiClient>((ref) {
  ref.watch(authUserIdProvider);
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
  const OrderCheckoutState({this.isSubmitting = false, this.lastOrder});

  final bool isSubmitting;
  final Order? lastOrder;
}

class OrderCheckoutController extends AsyncNotifier<OrderCheckoutState> {
  OrderRepository get _repository => ref.read(orderRepositoryProvider);

  @override
  Future<OrderCheckoutState> build() async {
    ref.watch(authUserIdProvider);
    return const OrderCheckoutState();
  }

  Future<Order?> submit(CreateOrderRequest request) async {
    if (state.value?.isSubmitting == true) return null;

    state = AsyncData(const OrderCheckoutState(isSubmitting: true));

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
    ref.watch(authUserIdProvider);
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

    final next = await _repository.fetchOrders(page: current.currentPage + 1);
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

final orderTrackingControllerProvider =
    AsyncNotifierProvider<OrderTrackingController, OrderTracking?>(
      OrderTrackingController.new,
    );

class OrderTrackingController extends AsyncNotifier<OrderTracking?> {
  OrderRepository get _repository => ref.read(orderRepositoryProvider);

  bool _requestInFlight = false;

  @override
  Future<OrderTracking?> build() async {
    ref.watch(authUserIdProvider);
    return null;
  }

  Future<void> load(
    String orderId, {
    bool showLoading = false,
  }) async {
    if (_requestInFlight) return;
    _requestInFlight = true;

    final previous = state;
    if (showLoading && !previous.hasValue) {
      state = const AsyncLoading();
    }

    try {
      final next = await AsyncValue.guard(
        () => _repository.fetchTracking(orderId),
      );

      // On refresh errors, keep the last successful tracking response visible
      // instead of replacing the entire screen with an error state.
      if (next.hasError && previous.hasValue) {
        // Keep the last successful tracking response visible during transient
        // refresh/poll failures instead of surfacing a full-page error.
        state = AsyncData(previous.value);
      } else {
        state = next;
      }
    } finally {
      _requestInFlight = false;
    }
  }
}
