import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_transport.dart';
import '../../auth/data/session_store.dart';
import '../data/invoice_models.dart';
import '../data/invoice_repository.dart';

final invoiceApiTransportProvider = Provider<HttpApiTransport>((ref) {
  final transport = HttpApiTransport();
  ref.onDispose(transport.close);
  return transport;
});

final invoiceSessionStoreProvider = Provider<SessionStore>((ref) => SecureSessionStore());

final invoiceApiClientProvider = Provider<ApiClient>((ref) => ApiClient(
  config: ApiConfig.fromEnvironment(),
  transport: ref.watch(invoiceApiTransportProvider),
  tokenProvider: ref.watch(invoiceSessionStoreProvider).readToken,
));

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) => RemoteInvoiceRepository(ref.watch(invoiceApiClientProvider)));

final invoiceControllerProvider = AsyncNotifierProvider<InvoiceController, Invoice?>(InvoiceController.new);

class InvoiceController extends AsyncNotifier<Invoice?> {
  InvoiceRepository get _repository => ref.read(invoiceRepositoryProvider);

  @override
  Future<Invoice?> build() async => null;

  Future<void> load(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.fetchInvoice(orderId));
  }
}
