import 'package:flutter_test/flutter_test.dart';

import 'package:snap_foodd/features/delivery/data/delivery_location_adapter.dart';
import 'package:snap_foodd/features/delivery/presentation/active_delivery_location_controller.dart';

void main() {
  test('unconfigured location source reports unavailable without emitting GPS', () async {
    final source = UnavailableDeliveryLocationSource();
    expect(
      await source.requestPermission(),
      DeliveryLocationPermission.unavailable,
    );
    expect(source.positions, emitsDone);
    await source.dispose();
  });
}
