import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'delivery_models.dart';

abstract interface class DeliveryRepository {
  Future<DeliveryAssignmentPage> fetchAssignments({int page = 1});
  Future<DeliveryAssignment> updateStatus(int assignmentId, String status);
  Future<Object?> updateLocation(
    int assignmentId,
    DeliveryLocationUpdate location,
  );
}

class RemoteDeliveryRepository implements DeliveryRepository {
  const RemoteDeliveryRepository(this._client);
  final ApiClient _client;

  @override
  Future<DeliveryAssignmentPage> fetchAssignments({int page = 1}) async {
    final response = await _client.get(
      '/delivery/assignments',
      queryParameters: {'page': '$page'},
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map)
        return DeliveryAssignmentPage.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ApiException(
      message:
          'The server returned an unexpected delivery assignment response.',
      code: 'INVALID_RESPONSE',
    );
  }

  @override
  Future<DeliveryAssignment> updateStatus(
    int assignmentId,
    String status,
  ) async {
    if (assignmentId <= 0)
      throw const ApiException(
        message: 'A valid assignment id is required.',
        code: 'INVALID_ASSIGNMENT_ID',
      );
    if (!const {
      'PICKED_UP',
      'OUT_FOR_DELIVERY',
      'DELIVERED',
    }.contains(status)) {
      throw const ApiException(
        message: 'The delivery status is invalid.',
        code: 'INVALID_DELIVERY_STATUS',
      );
    }
    final response = await _client.request(
      'PATCH',
      '/delivery/assignments/$assignmentId/status',
      body: {'status': status},
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map)
        return DeliveryAssignment.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ApiException(
      message: 'The server returned an unexpected delivery status response.',
      code: 'INVALID_RESPONSE',
    );
  }

  @override
  Future<Object?> updateLocation(
    int assignmentId,
    DeliveryLocationUpdate location,
  ) async {
    if (assignmentId <= 0)
      throw const ApiException(
        message: 'A valid assignment id is required.',
        code: 'INVALID_ASSIGNMENT_ID',
      );
    return _client.post(
      '/delivery/assignments/$assignmentId/location',
      body: location.toJson(),
    );
  }
}
