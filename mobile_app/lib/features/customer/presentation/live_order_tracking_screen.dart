import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import 'order_controller.dart';
import '../data/order_models.dart';
import '../data/order_tracking_models.dart';

class LiveOrderTrackingScreen extends ConsumerStatefulWidget {
  const LiveOrderTrackingScreen({super.key, required this.orderId});
  final String orderId;

  @override
  ConsumerState<LiveOrderTrackingScreen> createState() =>
      _LiveOrderTrackingScreenState();
}

class _LiveOrderTrackingScreenState
    extends ConsumerState<LiveOrderTrackingScreen> {
  Timer? _poller;

  @override
  void initState() {
    super.initState();
    if (widget.orderId.trim().isNotEmpty) {
      Future.microtask(_load);
      _poller = Timer.periodic(const Duration(seconds: 10), (_) => _load());
    }
  }

  Future<void> _load() async {
    if (!mounted || widget.orderId.trim().isEmpty) return;
    await ref
        .read(orderTrackingControllerProvider.notifier)
        .load(widget.orderId);
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(orderTrackingControllerProvider);
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      appBar: AppBar(
        title: Text(
          widget.orderId.isEmpty
              ? 'Track Order'
              : 'Track #' + widget.orderId,
        ),
        backgroundColor: SnapFoodColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: widget.orderId.trim().isEmpty
          ? const _Unavailable(
              message: 'Open tracking from a specific order to see live status.',
            )
          : tracking.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorView(error: error, onRetry: _load),
              data: (value) => value == null
                  ? const _Unavailable(
                      message: 'Delivery tracking is not available yet.',
                    )
                  : _TrackingBody(
                      orderId: widget.orderId,
                      tracking: value,
                    ),
            ),
    );
  }
}

class _TrackingBody extends ConsumerWidget {
  const _TrackingBody({required this.orderId, required this.tracking});
  final String orderId;
  final OrderTracking tracking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = _stepFor(tracking.status);
    final location = tracking.latestLocation;

    return RefreshIndicator(
      onRefresh: () => ref
          .read(orderTrackingControllerProvider.notifier)
          .load(orderId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SnapFoodColors.primaryContainer,
              borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
            ),
            child: Row(
              children: [
                const Icon(Icons.delivery_dining,
                    color: SnapFoodColors.warmBlack, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _labelFor(tracking.status),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tracking.isStale
                            ? 'Last location update is stale.'
                            : location == null
                            ? 'Waiting for delivery partner location.'
                            : 'Location is updating automatically.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: SnapFoodColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!tracking.isStale) const _LiveBadge(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Timeline(current: current),
          const SizedBox(height: 14),
          _LocationCard(location: location, stale: tracking.isStale),
          const SizedBox(height: 14),
          const Text(
            'Tracking refreshes automatically while this screen is open.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: SnapFoodColors.outline),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.current});
  final int current;

  static const steps = [
    'Order placed',
    'Restaurant accepted',
    'Preparing your food',
    'Ready for pickup',
    'Delivery partner assigned',
    'Picked up',
    'On the way',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order progress',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < steps.length; i++)
              _StepRow(
                label: steps[i],
                active: current >= i,
                current: current == i,
                last: i == steps.length - 1,
              ),
          ],
        ),
      );
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.active,
    required this.current,
    required this.last,
  });
  final String label;
  final bool active;
  final bool current;
  final bool last;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: last ? 38 : 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: current ? 15 : 12,
                    height: current ? 15 : 12,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: active
                          ? SnapFoodColors.secondary
                          : SnapFoodColors.softBorder,
                      shape: BoxShape.circle,
                      border: current
                          ? Border.all(
                              color: SnapFoodColors.softRed, width: 4)
                          : null,
                    ),
                  ),
                  if (!last)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: active
                            ? SnapFoodColors.secondary
                            : SnapFoodColors.softBorder,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: current ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
            if (active)
              const Icon(Icons.check_circle,
                  color: SnapFoodColors.secondary, size: 16),
          ],
        ),
      );
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location, required this.stale});
  final OrderTrackingLocation? location;
  final bool stale;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery location',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            if (location == null)
              const Text(
                'The delivery partner has not shared a location yet.',
                style: TextStyle(
                  fontSize: 11,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              )
            else ...[
              Text(
                'Lat ' +
                    location!.latitude.toStringAsFixed(5) +
                    '  •  Lng ' +
                    location!.longitude.toStringAsFixed(5),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                stale
                    ? 'This location may be outdated.'
                    : location!.recordedAt == null
                    ? 'Latest location received.'
                    : 'Updated ' + location!.recordedAt!.toLocal().toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      );
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: SnapFoodColors.softYellow,
          borderRadius: BorderRadius.circular(SnapFoodRadii.full),
        ),
        child: const Text(
          'LIVE',
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900),
        ),
      );
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: SnapFoodColors.onSurfaceVariant,
            ),
          ),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is ApiException
        ? (error as ApiException).message
        : 'We could not load live tracking.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

int _stepFor(String status) {
  const steps = [
    'PLACED',
    'ACCEPTED',
    'PREPARING',
    'READY_FOR_PICKUP',
    'ASSIGNED',
    'PICKED_UP',
    'OUT_FOR_DELIVERY',
    'DELIVERED',
  ];
  final index = steps.indexOf(status.toUpperCase());
  return index < 0 ? 0 : index;
}

String _labelFor(String status) => switch (OrderStatus.fromWire(status)) {
  OrderStatus.placed => 'Order placed',
  OrderStatus.accepted => 'Restaurant accepted',
  OrderStatus.preparing => 'Preparing your food',
  OrderStatus.readyForPickup => 'Ready for pickup',
  OrderStatus.assigned => 'Delivery partner assigned',
  OrderStatus.pickedUp => 'Picked up',
  OrderStatus.outForDelivery => 'On the way',
  OrderStatus.delivered => 'Delivered',
  OrderStatus.cancelled => 'Order cancelled',
  OrderStatus.unknown => status.isEmpty ? 'Status unavailable' : status,
};
