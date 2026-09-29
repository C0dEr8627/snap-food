import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_transport.dart';
import '../../auth/data/session_store.dart';
import '../data/delivery_models.dart';
import '../data/delivery_repository.dart';

final deliveryApiTransportProvider = Provider<HttpApiTransport>((ref) {
  final transport = HttpApiTransport();
  ref.onDispose(transport.close);
  return transport;
});

final deliverySessionStoreProvider = Provider<SessionStore>((ref) => SecureSessionStore());

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return RemoteDeliveryRepository(
    ApiClient(
      config: ApiConfig.fromEnvironment(),
      transport: ref.watch(deliveryApiTransportProvider),
      tokenProvider: ref.watch(deliverySessionStoreProvider).readToken,
    ),
  );
});

final deliveryAssignmentsProvider = FutureProvider.autoDispose<DeliveryAssignmentPage>((ref) {
  return ref.watch(deliveryRepositoryProvider).fetchAssignments();
});

final activeDeliveryAssignmentProvider = Provider<DeliveryAssignment?>((ref) {
  final assignments = ref.watch(deliveryAssignmentsProvider);
  return assignments.maybeWhen(
    data: (page) {
      for (final assignment in page.items) {
        if (assignment.status == 'PICKED_UP' || assignment.status == 'OUT_FOR_DELIVERY') {
          return assignment;
        }
      }
      return null;
    },
    orElse: () => null,
  );
});

final deliveryStatusMutationProvider = Provider<DeliveryStatusMutation>((ref) {
  return DeliveryStatusMutation(ref.watch(deliveryRepositoryProvider));
});

class DeliveryStatusMutation {
  DeliveryStatusMutation(this._repository);
  final DeliveryRepository _repository;

  Future<DeliveryAssignment> advance(DeliveryAssignment assignment) {
    final next = switch (assignment.status) {
      'PICKED_UP' => 'OUT_FOR_DELIVERY',
      'OUT_FOR_DELIVERY' => 'DELIVERED',
      _ => 'PICKED_UP',
    };
    return _repository.updateStatus(assignment.id, next);
  }
}
