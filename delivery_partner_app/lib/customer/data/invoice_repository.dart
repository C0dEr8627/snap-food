import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'invoice_models.dart';

abstract interface class InvoiceRepository {
  Future<Invoice> fetchInvoice(String orderId);
}

class RemoteInvoiceRepository implements InvoiceRepository {
  const RemoteInvoiceRepository(this._client);
  final ApiClient _client;

  @override
  Future<Invoice> fetchInvoice(String orderId) async {
    final normalized = orderId.trim();
    if (normalized.isEmpty)
      throw const ApiException(
        message: 'An order id is required.',
        code: 'INVALID_ORDER_ID',
      );
    final response = await _client.get(
      '/consumer/orders/' + Uri.encodeComponent(normalized) + '/invoice',
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map) return Invoice.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ApiException(
      message: 'The server returned an unexpected invoice response.',
      code: 'INVALID_RESPONSE',
    );
  }
}

class FakeInvoiceRepository implements InvoiceRepository {
  FakeInvoiceRepository({Invoice? invoice}) : _invoice = invoice;
  final Invoice? _invoice;

  @override
  Future<Invoice> fetchInvoice(String orderId) async {
    if (_invoice == null)
      throw const ApiException(
        message: 'No invoice fixture was supplied.',
        code: 'FIXTURE_MISSING',
      );
    return _invoice;
  }
}
