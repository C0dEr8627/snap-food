import 'package:flutter_test/flutter_test.dart';
import 'package:snap_foodd/features/customer/data/invoice_models.dart';
import 'package:snap_foodd/features/customer/data/invoice_repository.dart';

void main() {
  test('decodes the frozen invoice response shape', () {
    final invoice = Invoice.fromJson({
      'id': 7, 'order_id': 42, 'invoice_number': 'INV-2026-00000042',
      'customer_name': 'Demo Customer', 'customer_email': 'demo@example.com',
      'delivery_address_snapshot': {'label': 'Home', 'recipient_name': 'Demo Customer', 'address_line1': '10 Example Road', 'city': 'Mumbai', 'state': 'Maharashtra', 'postal_code': '400001', 'country': 'India'},
      'items': [{'product_id': 15, 'product_name': 'Biryani', 'unit_price': '240.00', 'quantity': 2, 'line_total': '480.00'}],
      'subtotal': '480.00', 'delivery_fee': '40.00', 'total': '520.00',
      'payment_method': 'COD', 'payment_status': 'PENDING',
      'issued_at': '2026-09-29T12:00:00+00:00', 'file_reference': null,
    });

    expect(invoice.id, 7);
    expect(invoice.orderId, 42);
    expect(invoice.invoiceNumber, 'INV-2026-00000042');
    expect(invoice.items.single.quantity, 2);
    expect(invoice.deliveryAddress?.city, 'Mumbai');
    expect(invoice.total, '520.00');
  });

  test('fake repository returns the supplied invoice fixture', () async {
    const invoice = Invoice(id: 1, orderId: 2, invoiceNumber: 'INV-2026-00000002', customerName: 'Customer', deliveryAddress: null, items: [], subtotal: '10.00', deliveryFee: '2.00', total: '12.00', paymentMethod: 'COD', paymentStatus: 'PAID');
    final result = await FakeInvoiceRepository(invoice: invoice).fetchInvoice('2');
    expect(result.invoiceNumber, 'INV-2026-00000002');
  });
}
