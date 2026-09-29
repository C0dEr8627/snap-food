import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/delivery_location_adapter.dart';
import '../data/delivery_repository.dart';
import 'delivery_controller.dart';

enum ActiveDeliveryLocationState {
  idle,
  requestingPermission,
  tracking,
  permissionDenied,
  unavailable,
  error,
}

class ActiveDeliveryLocationController extends Notifier<ActiveDeliveryLocationState> {
  late DeliveryRepository _repository;
  late ForegroundDeliveryLocationAdapter _adapter;
  int? _assignmentId;
  DateTime? _lastPublishedAt;

  @override
  ActiveDeliveryLocationState build() {
    _repository = ref.watch(deliveryRepositoryProvider);
    _adapter = ref.watch(deliveryLocationAdapterProvider);
    ref.onDispose(_adapter.stop);
    return ActiveDeliveryLocationState.idle;
  }

  int? get assignmentId => _assignmentId;
  DateTime? get lastPublishedAt => _lastPublishedAt;

  Future<void> start(int assignmentId) async {
    if (assignmentId <= 0) {
      state = ActiveDeliveryLocationState.error;
      return;
    }
    if (_assignmentId == assignmentId && _adapter.isRunning) return;

    await stop();
    _assignmentId = assignmentId;
    _lastPublishedAt = null;
    state = ActiveDeliveryLocationState.requestingPermission;

    final permission = await _adapter.start(
      onPosition: (position) {
        final id = _assignmentId;
        if (id == null || !_adapter.isRunning) return;
        unawaited(_publish(id, position));
      },
    );

    state = switch (permission) {
      DeliveryLocationPermission.granted => ActiveDeliveryLocationState.tracking,
      DeliveryLocationPermission.denied ||
      DeliveryLocationPermission.deniedForever =>
        ActiveDeliveryLocationState.permissionDenied,
      DeliveryLocationPermission.unavailable => ActiveDeliveryLocationState.unavailable,
    };
  }

  Future<void> _publish(int id, DeliveryPosition position) async {
    try {
      await _repository.updateLocation(
        id,
        DeliveryLocationUpdate(
          latitude: position.latitude,
          longitude: position.longitude,
          recordedAt: position.recordedAt,
          accuracy: position.accuracy,
        ),
      );
      if (_assignmentId == id && _adapter.isRunning) {
        _lastPublishedAt = DateTime.now().toUtc();
        state = ActiveDeliveryLocationState.tracking;
      }
    } catch (_) {
      if (_assignmentId == id && _adapter.isRunning) {
        state = ActiveDeliveryLocationState.error;
      }
    }
  }

  Future<void> stop() async {
    await _adapter.stop();
    _assignmentId = null;
    _lastPublishedAt = null;
    if (state != ActiveDeliveryLocationState.idle) {
      state = ActiveDeliveryLocationState.idle;
    }
  }
}

final deliveryLocationAdapterProvider = Provider<ForegroundDeliveryLocationAdapter>((ref) {
  return ForegroundDeliveryLocationAdapter(
    source: UnavailableDeliveryLocationSource(),
  );
});

final activeDeliveryLocationControllerProvider = NotifierProvider<
    ActiveDeliveryLocationController,
    ActiveDeliveryLocationState>(
  ActiveDeliveryLocationController.new,
);

class UnavailableDeliveryLocationSource implements DeliveryLocationSource {
  @override
  Future<DeliveryLocationPermission> requestPermission() async =>
      DeliveryLocationPermission.unavailable;

  @override
  Stream<DeliveryPosition> get positions =>
      const Stream<DeliveryPosition>.empty();

  @override
  Future<void> dispose() async {}
}
