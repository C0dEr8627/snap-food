import 'dart:async';

class DeliveryPosition {
  const DeliveryPosition({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.accuracy,
  });

  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double? accuracy;
}

enum DeliveryLocationPermission { granted, denied, deniedForever, unavailable }

abstract interface class DeliveryLocationSource {
  Future<DeliveryLocationPermission> requestPermission();

  Stream<DeliveryPosition> get positions;

  Future<void> dispose();
}

/// Foreground-only adapter used by the active delivery trip.
///
/// The platform implementation is deliberately injected. This keeps GPS,
/// permission APIs and platform plugins out of the delivery domain layer.
/// It also guarantees that no location stream is started until an active
/// assignment explicitly subscribes to it.
class ForegroundDeliveryLocationAdapter {
  ForegroundDeliveryLocationAdapter({
    required DeliveryLocationSource source,
    Duration updateInterval = const Duration(seconds: 5),
  }) : _source = source,
       _updateInterval = updateInterval;

  final DeliveryLocationSource _source;
  final Duration _updateInterval;

  StreamSubscription<DeliveryPosition>? _subscription;
  Timer? _throttleTimer;
  DeliveryPosition? _pending;
  bool _running = false;

  bool get isRunning => _running;

  Future<DeliveryLocationPermission> start({
    required void Function(DeliveryPosition position) onPosition,
  }) async {
    if (_running) return DeliveryLocationPermission.granted;

    final permission = await _source.requestPermission();
    if (permission != DeliveryLocationPermission.granted) {
      return permission;
    }

    _running = true;
    _subscription = _source.positions.listen(
      (position) {
        _pending = position;
        _flushIfReady(onPosition);
      },
      onError: (_) {
        // The owner observes source errors through its own UI/controller
        // boundary. The adapter stops emitting but does not fabricate data.
      },
    );
    return permission;
  }

  void _flushIfReady(void Function(DeliveryPosition) onPosition) {
    if (_throttleTimer != null) return;
    final position = _pending;
    _pending = null;
    if (position == null) return;

    onPosition(position);
    _throttleTimer = Timer(_updateInterval, () {
      _throttleTimer = null;
      final next = _pending;
      _pending = null;
      if (next != null && _running) {
        onPosition(next);
        _throttleTimer = Timer(_updateInterval, () {
          _throttleTimer = null;
          if (_pending != null && _running) {
            final latest = _pending;
            _pending = null;
            if (latest != null) onPosition(latest);
          }
        });
      }
    });
  }

  Future<void> stop() async {
    _running = false;
    _pending = null;
    _throttleTimer?.cancel();
    _throttleTimer = null;
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async {
    await stop();
    await _source.dispose();
  }
}
