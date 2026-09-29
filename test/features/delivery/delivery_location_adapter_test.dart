import 'package:flutter_test/flutter_test.dart';

import 'package:snap_foodd/features/delivery/data/delivery_location_adapter.dart';

class _FakeLocationSource implements DeliveryLocationSource {
  final controller = StreamController<DeliveryPosition>.broadcast();
  DeliveryLocationPermission permission = DeliveryLocationPermission.granted;

  @override
  Future<DeliveryLocationPermission> requestPermission() async => permission;

  @override
  Stream<DeliveryPosition> get positions => controller.stream;

  @override
  Future<void> dispose() => controller.close();
}

void main() {
  test('does not subscribe when permission is denied', () async {
    final source = _FakeLocationSource()
      ..permission = DeliveryLocationPermission.denied;
    final adapter = ForegroundDeliveryLocationAdapter(source: source);

    final result = await adapter.start(onPosition: (_) {});

    expect(result, DeliveryLocationPermission.denied);
    expect(adapter.isRunning, isFalse);
    await adapter.dispose();
  });

  test('emits the first foreground position and stops cleanly', () async {
    final source = _FakeLocationSource();
    final adapter = ForegroundDeliveryLocationAdapter(
      source: source,
      updateInterval: const Duration(seconds: 30),
    );
    final received = <DeliveryPosition>[];

    final result = await adapter.start(onPosition: received.add);
    expect(result, DeliveryLocationPermission.granted);

    source.controller.add(
      DeliveryPosition(
        latitude: 19.076,
        longitude: 72.8777,
        recordedAt: DateTime.utc(2026, 9, 29, 12),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(received, hasLength(1));
    expect(received.single.latitude, 19.076);
    expect(adapter.isRunning, isTrue);

    await adapter.stop();
    expect(adapter.isRunning, isFalse);
    await adapter.dispose();
  });

  test('coalesces positions during the throttle interval', () async {
    final source = _FakeLocationSource();
    final adapter = ForegroundDeliveryLocationAdapter(
      source: source,
      updateInterval: const Duration(milliseconds: 20),
    );
    final received = <DeliveryPosition>[];

    await adapter.start(onPosition: received.add);
    source.controller.add(DeliveryPosition(
      latitude: 1,
      longitude: 2,
      recordedAt: DateTime.utc(2026, 9, 29),
    ));
    source.controller.add(const DeliveryPosition(
      latitude: 3,
      longitude: 4,
      recordedAt: DateTime.utc(2026, 9, 29, 0, 0, 1),
    ));
    await Future<void>.delayed(const Duration(milliseconds: 5));

    expect(received, hasLength(1));
    expect(received.single.latitude, 1);

    await Future<void>.delayed(const Duration(milliseconds: 25));
    expect(received, hasLength(2));
    expect(received.last.latitude, 3);

    await adapter.dispose();
  });
}
