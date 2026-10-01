import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'order_models.dart';
import 'order_tracking_models.dart';

abstract interface class OrderRepository {
  Future<Order> createOrder(CreateOrderRequest request);
  Future<OrderPage> fetchOrders({int? page, int? perPage});
  Future<Order> fetchOrder(String orderId);
  Future<OrderTracking> fetchTracking(String orderId);
}

class RemoteOrderRepository implements OrderRepository {
  const RemoteOrderRepository(this._client);

  final ApiClient _client;

  @override
  Future<Order> createOrder(CreateOrderRequest request) async {
    final response = await _client.post('/consumer/orders', body: request.toJson());
    return _decodeOrder(response);
  }

  @override
  Future<OrderPage> fetchOrders({int? page, int? perPage}) async {
    final query = <String, String>{
      if (page != null) 'page': '$page',
      if (perPage != null) 'per_page': '$perPage',
    };
    final response = await _client.get('/consumer/orders', queryParameters: query);
    return _decodePage(response);
  }

  @override
  Future<OrderTracking> fetchTracking(String orderId) async {
    if (orderId.trim().isEmpty) {
      throw const ApiException(
        message: 'An order id is required.',
        code: 'INVALID_ORDER_ID',
      );
    }
    final response = await _client.get(
      '/consumer/orders/' + Uri.encodeComponent(orderId) + '/tracking',
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map)
        return OrderTracking.fromJson(Map<String, dynamic>.from(data));
      if (response['status'] != null) return OrderTracking.fromJson(response);
    }
    throw const ApiException(
      message: 'The server returned an unexpected tracking response.',
      code: 'INVALID_RESPONSE',
    );
  }

  @override
  Future<Order> fetchOrder(String orderId) async {
    if (orderId.trim().isEmpty) {
      throw const ApiException(
        message: 'An order id is required.',
        code: 'INVALID_ORDER_ID',
      );
    }
    final path = '/consumer/orders/' + Uri.encodeComponent(orderId);
    final response = await _client.get(path);
    return _decodeOrder(response);
  }

  Order _decodeOrder(Object? response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map) {
        return Order.fromJson(Map<String, dynamic>.from(data));
      }
      if (response['id'] != null) return Order.fromJson(response);
    }
    throw const ApiException(
      message: 'The server returned an unexpected order response.',
      code: 'INVALID_RESPONSE',
    );
  }

  OrderPage _decodePage(Object? response) {
    if (response is List) {
      final orders = response
          .whereType<Map>()
          .map((item) => Order.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
      return OrderPage(orders: orders, currentPage: 1, lastPage: 1, total: orders.length);
    }
    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'The server returned an unexpected order list response.',
        code: 'INVALID_RESPONSE',
      );
    }

    final outerData = response['data'];
    // Support both Laravel paginator envelopes ({data: {data: [...]}})
    // and simple PHP API collection envelopes ({data: [...]} / {orders: [...]}).
    final Object? rawPage = outerData is Map ? outerData : response;
    final page = rawPage is Map ? Map<String, dynamic>.from(rawPage) : <String, dynamic>{};
    final Object? rawItems = outerData is List
        ? outerData
        : (page['data'] is List ? page['data'] : page['orders']);
    if (rawItems is! List) {
      throw const ApiException(
        message: 'The server returned an unexpected order list payload.',
        code: 'INVALID_RESPONSE',
      );
    }

    int integer(Object? value, [int fallback = 0]) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

    final parsedOrders = rawItems
        .whereType<Map>()
        .map((item) => Order.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    return OrderPage(
      orders: parsedOrders,
      currentPage: integer(page['current_page'], 1),
      lastPage: integer(page['last_page'], 1),
      total: integer(page['total'], parsedOrders.length),
    );
  }
}

class FakeOrderRepository implements OrderRepository {
  FakeOrderRepository({Iterable<Order> orders = const [], Order? createdOrder})
    : _orders = List.unmodifiable(orders),
      _createdOrder = createdOrder;

  final List<Order> _orders;
  final Order? _createdOrder;
  CreateOrderRequest? lastCreateRequest;

  @override
  Future<Order> createOrder(CreateOrderRequest request) async {
    lastCreateRequest = request;
    if (_createdOrder == null) {
      throw const ApiException(
        message: 'No checkout fixture was supplied.',
        code: 'FIXTURE_MISSING',
      );
    }
    return _createdOrder;
  }

  @override
  Future<OrderPage> fetchOrders({int? page, int? perPage}) async {
    return OrderPage(
      orders: _orders,
      currentPage: page ?? 1,
      lastPage: 1,
      total: _orders.length,
    );
  }

  @override
  Future<OrderTracking> fetchTracking(String orderId) async {
    throw const ApiException(
      message: 'Tracking is not available in the local fixture.',
      code: 'FIXTURE_MISSING',
    );
  }

  @override
  Future<Order> fetchOrder(String orderId) async {
    for (final order in _orders) {
      if (order.id == orderId) return order;
    }
    throw const ApiException(
      message: 'Order not found in the local fixture.',
      statusCode: 404,
      code: 'NOT_FOUND',
    );
  }
}
