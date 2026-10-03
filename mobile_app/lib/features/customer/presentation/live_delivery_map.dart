import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../data/order_tracking_models.dart';

class LiveDeliveryMap extends StatefulWidget {
  const LiveDeliveryMap({
    super.key,
    required this.destination,
    this.driverLocation,
    this.stale = false,
  });

  final OrderTrackingDestination destination;
  final OrderTrackingLocation? driverLocation;
  final bool stale;

  @override
  State<LiveDeliveryMap> createState() => _LiveDeliveryMapState();
}

class _LiveDeliveryMapState extends State<LiveDeliveryMap> {
  GoogleMapController? _controller;
  LatLng? _lastDriverPosition;

  LatLng get _destination =>
      LatLng(widget.destination.latitude, widget.destination.longitude);

  LatLng? get _driver => widget.driverLocation == null
      ? null
      : LatLng(
          widget.driverLocation!.latitude,
          widget.driverLocation!.longitude,
        );

  @override
  void didUpdateWidget(covariant LiveDeliveryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _driver;
    if (next == null || next == _lastDriverPosition) return;
    _lastDriverPosition = next;
    unawaited(_followDriver(next));
  }

  Future<void> _followDriver(LatLng position) async {
    final controller = _controller;
    if (controller == null || !mounted) return;
    await controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    final driver = _driver;
    if (driver != null) {
      _lastDriverPosition = driver;
      unawaited(
        controller.animateCamera(CameraUpdate.newLatLngZoom(driver, 15)),
      );
    } else {
      unawaited(
        controller.animateCamera(CameraUpdate.newLatLngZoom(_destination, 15)),
      );
    }
  }

  Set<Marker> get _markers {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('destination'),
        position: _destination,
        infoWindow: const InfoWindow(title: 'Delivery address'),
      ),
    };

    final driver = _driver;
    if (driver != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('delivery_partner'),
          position: driver,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            widget.stale
                ? BitmapDescriptor.hueOrange
                : BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: widget.stale
                ? 'Delivery partner (last known)'
                : 'Delivery partner',
          ),
        ),
      );
    }

    return markers;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasDriver = widget.driverLocation != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: hasDriver ? _driver! : _destination,
                zoom: 15,
              ),
              markers: _markers,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              onMapCreated: _onMapCreated,
            ),
          ),
          Positioned(
            left: SnapFoodSpacing.sm,
            right: SnapFoodSpacing.sm,
            bottom: SnapFoodSpacing.sm,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SnapFoodSpacing.sm,
                    vertical: SnapFoodSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasDriver
                            ? Icons.delivery_dining_rounded
                            : Icons.location_on_rounded,
                        size: 17,
                      ),
                      const SizedBox(width: SnapFoodSpacing.xs),
                      Expanded(
                        child: Text(
                          hasDriver
                              ? widget.stale
                                  ? 'Showing the last known delivery location'
                                  : 'Live delivery location'
                              : 'Delivery destination',
                          style: SnapFoodTypography.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
