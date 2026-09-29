import 'order_models.dart';

class InvoiceItem {
  const InvoiceItem({required this.productId, required this.productName, required this.unitPrice, required this.quantity, required this.lineTotal});

  final int productId;
  final String productName;
  final String unitPrice;
  final int quantity;
  final String lineTotal;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    productId: json['product_id'] is num ? (json['product_id'] as num).toInt() : int.tryParse(json['product_id']?.toString() ?? '') ?? 0,
    productName: json['product_name']?.toString() ?? '',
    unitPrice: json['unit_price']?.toString() ?? '',
    quantity: json['quantity'] is num ? (json['quantity'] as num).toInt() : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
    lineTotal: json['line_total']?.toString() ?? '',
  );
}

class Invoice {
  const Invoice({
    required this.id, required this.orderId, required this.invoiceNumber,
    required this.customerName, this.customerEmail, required this.deliveryAddress,
    required this.items, required this.subtotal, required this.deliveryFee,
    required this.total, required this.paymentMethod, required this.paymentStatus,
    this.issuedAt, this.fileReference,
  });

  final int id;
  final int orderId;
  final String invoiceNumber;
  final String customerName;
  final String? customerEmail;
  final DeliveryAddress? deliveryAddress;
  final List<InvoiceItem> items;
  final String subtotal;
  final String deliveryFee;
  final String total;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? issuedAt;
  final String? fileReference;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawAddress = json['delivery_address_snapshot'];
    final issued = json['issued_at']?.toString();
    return Invoice(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      orderId: json['order_id'] is num ? (json['order_id'] as num).toInt() : int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerEmail: json['customer_email']?.toString(),
      deliveryAddress: rawAddress is Map ? DeliveryAddress.fromJson(Map<String, dynamic>.from(rawAddress)) : null,
      items: rawItems is List ? rawItems.whereType<Map>().map((item) => InvoiceItem.fromJson(Map<String, dynamic>.from(item))).toList(growable: false) : const <InvoiceItem>[],
      subtotal: json['subtotal']?.toString() ?? '',
      deliveryFee: json['delivery_fee']?.toString() ?? '',
      total: json['total']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      issuedAt: issued == null ? null : DateTime.tryParse(issued),
      fileReference: json['file_reference']?.toString(),
    );
  }
}
