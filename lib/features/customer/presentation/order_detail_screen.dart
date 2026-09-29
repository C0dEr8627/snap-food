import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../data/order_models.dart';
import 'package:go_router/go_router.dart';
import 'order_controller.dart';
import '../data/order_tracking_models.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;
  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final order = await ref
          .read(orderHistoryControllerProvider.notifier)
          .loadDetail(widget.orderId);
      if (mounted &&
          order != null &&
          order.status != OrderStatus.delivered &&
          order.status != OrderStatus.cancelled) {
        await ref
            .read(orderTrackingControllerProvider.notifier)
            .load(widget.orderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderHistoryControllerProvider);
    final tracking = ref.watch(orderTrackingControllerProvider);
    final order = state.value?.selectedOrder;
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      appBar: AppBar(
        title: Text('Order #' + widget.orderId),
        backgroundColor: SnapFoodColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: FilledButton(
            onPressed: () => ref
                .read(orderHistoryControllerProvider.notifier)
                .loadDetail(widget.orderId),
            child: const Text('Retry'),
          ),
        ),
        data: (_) {
          if (order == null || order.id != widget.orderId)
            return const Center(child: CircularProgressIndicator());
          final canTrack =
              order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _StatusCard(status: _statusLabel(order.status)),
              if (canTrack) ...[
                const SizedBox(height: 12),
                _TrackingCard(
                  tracking: tracking,
                  onRetry: () => ref
                      .read(orderTrackingControllerProvider.notifier)
                      .load(widget.orderId),
                ),
              ],
              const SizedBox(height: 14),
              _Section(
                title: 'Items',
                child: Column(
                  children: [
                    for (final item in order.items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.productId.isEmpty
                              ? 'Product'
                              : 'Product ' + item.productId,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: Text(
                          '×' + item.quantity.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: 'Delivery address',
                child: order.deliveryAddress == null
                    ? const Text(
                        'Address snapshot unavailable.',
                        style: TextStyle(
                          fontSize: 11,
                          color: SnapFoodColors.onSurfaceVariant,
                        ),
                      )
                    : Text(
                        _addressText(order.deliveryAddress!),
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.45,
                          color: SnapFoodColors.onSurfaceVariant,
                        ),
                      ),
              ),
              if (order.status == OrderStatus.delivered) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/orders/' + widget.orderId + '/invoice'),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('View invoice'),
                ),
              ],
              const SizedBox(height: 12),
              _Section(
                title: 'Payment',
                child: Column(
                  children: [
                    _Row('Method', order.paymentMethod),
                    const SizedBox(height: 7),
                    _Row('Status', order.paymentStatus),
                    const Divider(height: 18),
                    _Row('Subtotal', order.subtotal),
                    const SizedBox(height: 7),
                    _Row('Delivery', order.deliveryFee),
                    const Divider(height: 18),
                    _Row('Total', order.total, strong: true),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _addressText(DeliveryAddress address) => [
    address.label,
    address.recipientName,
    address.addressLine1,
    if (address.addressLine2 != null && address.addressLine2!.isNotEmpty)
      address.addressLine2!,
    address.city,
    address.state,
    address.postalCode,
    address.country,
  ].where((part) => part.trim().isNotEmpty).join(', ');
  static String _statusLabel(OrderStatus status) => switch (status) {
    OrderStatus.placed => 'Placed',
    OrderStatus.accepted => 'Accepted',
    OrderStatus.preparing => 'Preparing',
    OrderStatus.readyForPickup => 'Ready for pickup',
    OrderStatus.assigned => 'Assigned',
    OrderStatus.pickedUp => 'Picked up',
    OrderStatus.outForDelivery => 'Out for delivery',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.cancelled => 'Cancelled',
    OrderStatus.unknown => 'Status unavailable',
  };
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: SnapFoodColors.primaryContainer,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.receipt_long_outlined,
          color: SnapFoodColors.warmBlack,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            status,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.strong = false});
  final String label;
  final String value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: strong ? 13 : 11,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
            color: strong
                ? SnapFoodColors.onSurface
                : SnapFoodColors.onSurfaceVariant,
          ),
        ),
      ),
      Text(
        value.isEmpty
            ? '—'
            : (label == 'Method' || label == 'Status' ? value : '₹' + value),
        style: TextStyle(
          fontSize: strong ? 14 : 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({required this.tracking, required this.onRetry});
  final AsyncValue<OrderTracking?> tracking;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: tracking.when(
      loading: () => const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text('Loading live delivery status…'),
        ],
      ),
      error: (_, __) => Row(
        children: [
          const Expanded(
            child: Text(
              'Delivery tracking is temporarily unavailable.',
              style: TextStyle(fontSize: 11),
            ),
          ),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
      data: (value) {
        if (value == null)
          return const Text(
            'Tracking is not available yet.',
            style: TextStyle(
              fontSize: 11,
              color: SnapFoodColors.onSurfaceVariant,
            ),
          );
        final location = value.latestLocation;
        final freshness = value.isStale
            ? 'Location is stale'
            : location == null
            ? 'Waiting for delivery location'
            : 'Location updated recently';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live delivery tracking',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              value.status.isEmpty ? 'Status unavailable' : value.status,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              freshness,
              style: TextStyle(
                fontSize: 11,
                color: value.isStale
                    ? SnapFoodColors.secondary
                    : SnapFoodColors.onSurfaceVariant,
              ),
            ),
            if (location != null) ...[
              const SizedBox(height: 8),
              Text(
                'Coordinates: ' +
                    location.latitude.toStringAsFixed(5) +
                    ', ' +
                    location.longitude.toStringAsFixed(5),
                style: const TextStyle(
                  fontSize: 10,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
              if (location.recordedAt != null)
                Text(
                  'Recorded: ' + location.recordedAt!.toLocal().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: SnapFoodColors.outline,
                  ),
                ),
            ],
          ],
        );
      },
    ),
  );
}
