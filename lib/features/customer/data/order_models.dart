enum OrderStatus {
  placed,
  accepted,
  preparing,
  readyForPickup,
  assigned,
  pickedUp,
  outForDelivery,
  delivered,
  cancelled,
  unknown;

  static OrderStatus fromWire(Object? value) => switch (value?.toString()) {
        'PLACED' => placed,
        'ACCEPTED' => accepted,
        'PREPARING' => preparing,
        'READY_FOR_PICKUP' => readyForPickup,
        'ASSIGNED' => assigned,
        'PICKED_UP' => pickedUp,
        'OUT_FOR_DELIVERY' => outForDelivery,
        'DELIVERED' => delivered,
        'CANCELLED' => cancelled,
        _ => unknown,
      };
}

class DeliveryAddress {
  const DeliveryAddress({
    required this.label,
    required this.recipientName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.latitude,
    this.longitude,
  });

  final String label;
  final String recipientName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;

  Map<String, Object?> toJson() => {
        'label': label,
        'recipient_name': recipientName,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    double? number(Object? value) =>
        value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');

    return DeliveryAddress(
      label: json['label']?.toString() ?? '',
      recipientName: json['recipient_name']?.toString() ?? '',
      addressLine1: json['address_line1']?.toString() ?? '',
      addressLine2: json['address_line2']?.toString(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      latitude: number(json['latitude']),
      longitude: number(json['longitude']),
    );
  }
}

class OrderLineRequest {
  const OrderLineRequest({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final int quantity;

  Map<String, Object> toJson() => {
        'product_id': productId,
        'quantity': quantity,
      };
}

class CreateOrderRequest {
  const CreateOrderRequest({
    required this.items,
    required this.deliveryAddress,
    this.paymentMethod = 'COD',
  });

  final List<OrderLineRequest> items;
  final DeliveryAddress deliveryAddress;
  final String paymentMethod;

  Map<String, Object?> toJson() => {
        'items': items.map((item) => item.toJson()).toList(growable: false),
        'delivery_address': deliveryAddress.toJson(),
        'payment_method': paymentMethod,
      };
}

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.quantity,
    required this.payload,
  });

  final String productId;
  final int quantity;
  final Map<String, dynamic> payload;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final rawQuantity = json['quantity'];
    final rawProduct = json['product'];
    final nestedProductId =
        rawProduct is Map ? rawProduct['id']?.toString() : null;
    return OrderItem(
      productId: (json['product_id'] ?? nestedProductId ?? '').toString(),
      quantity: rawQuantity is num
          ? rawQuantity.toInt()
          : int.tryParse('$rawQuantity') ?? 0,
      payload: Map<String, dynamic>.unmodifiable(json),
    );
  }
}

class Order {
  const Order({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.items,
    required this.deliveryAddress,
    required this.payload,
  });

  final String id;
  final OrderStatus status;
  final String paymentMethod;
  final String paymentStatus;
  final String subtotal;
  final String deliveryFee;
  final String total;
  final List<OrderItem> items;
  final DeliveryAddress? deliveryAddress;
  final Map<String, dynamic> payload;

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((item) => OrderItem.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false)
        : const <OrderItem>[];

    final rawAddress = json['delivery_address_snapshot'];
    return Order(
      id: (json['id'] ?? '').toString(),
      status: OrderStatus.fromWire(json['status']),
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      subtotal: json['subtotal']?.toString() ?? '',
      deliveryFee: json['delivery_fee']?.toString() ?? '',
      total: json['total']?.toString() ?? '',
      items: items,
      deliveryAddress: rawAddress is Map
          ? DeliveryAddress.fromJson(Map<String, dynamic>.from(rawAddress))
          : null,
      payload: Map<String, dynamic>.unmodifiable(json),
    );
  }
}

class OrderPage {
  const OrderPage({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<Order> orders;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasNextPage => currentPage < lastPage;
}
