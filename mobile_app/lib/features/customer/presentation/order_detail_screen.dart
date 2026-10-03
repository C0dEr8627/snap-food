import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/snap_food_button.dart';
import '../../../design_system/components/snap_food_commerce.dart';
import '../../../design_system/components/snap_food_feedback.dart';
import '../../../design_system/components/snap_order_status.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../data/order_models.dart';
import '../data/order_tracking_models.dart';
import 'order_controller.dart';

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
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final order = await ref.read(orderHistoryControllerProvider.notifier).loadDetail(widget.orderId);
    if (!mounted || order == null || order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) return;
    await ref.read(orderTrackingControllerProvider.notifier).load(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderHistoryControllerProvider);
    final tracking = ref.watch(orderTrackingControllerProvider);
    final order = state.value?.selectedOrder;

    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: SnapFoodColors.surface,
              surfaceTintColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.only(left: SnapFoodSpacing.sm),
                child: SnapIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  semanticLabel: 'Back to orders',
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/orders');
                    }
                  },
                ),
              ),
              title: Text(
                'Order #${widget.orderId}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SnapFoodTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(SnapFoodSpacing.md, SnapFoodSpacing.sm, SnapFoodSpacing.md, SnapFoodSpacing.xxl),
              sliver: state.when(
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: SnapLoadingState(message: 'Loading order details…'),
                ),
                error: (error, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: SnapErrorState(title: 'Order details unavailable', message: error.toString(), onRetry: _load),
                ),
                data: (_) {
                  if (order == null || order.id != widget.orderId) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: SnapEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Order not found',
                        message: 'We could not find the requested order.',
                      ),
                    );
                  }

                  final canTrack = order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled;

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      _OrderHero(order: order),
                      const SizedBox(height: SnapFoodSpacing.lg),
                      SnapSectionHeader(
                        title: 'Items',
                        subtitle: order.items.length.toString(),
                      ),
                      const SizedBox(height: SnapFoodSpacing.sm),
                      _ItemsSection(items: order.items),
                      const SizedBox(height: SnapFoodSpacing.lg),
                      const SnapSectionHeader(title: 'Delivery'),
                      const SizedBox(height: SnapFoodSpacing.sm),
                      _DeliverySection(address: order.deliveryAddress),
                      const SizedBox(height: SnapFoodSpacing.lg),
                      const SnapSectionHeader(title: 'Payment & total'),
                      const SizedBox(height: SnapFoodSpacing.sm),
                      _PaymentSection(order: order),
                      if (canTrack) ...[
                        const SizedBox(height: SnapFoodSpacing.lg),
                        _TrackingPreview(
                          tracking: tracking,
                          onRetry: () => ref.read(orderTrackingControllerProvider.notifier).load(widget.orderId),
                        ),
                        const SizedBox(height: SnapFoodSpacing.sm),
                        SnapPrimaryButton(
                          label: 'Open live tracking',
                          icon: Icons.location_searching_outlined,
                          onPressed: () => context.push('/orders/${Uri.encodeComponent(widget.orderId)}/tracking'),
                        ),
                      ],
                      if (order.status == OrderStatus.delivered) ...[
                        const SizedBox(height: SnapFoodSpacing.lg),
                        SnapSecondaryButton(
                          label: 'View invoice',
                          icon: Icons.receipt_long_outlined,
                          onPressed: () => context.push('/orders/${Uri.encodeComponent(widget.orderId)}/invoice'),
                        ),
                      ],
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderHero extends StatelessWidget {
  const _OrderHero({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        label: 'Order ${order.id}. ${_statusLabel(order.status)}.',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SnapFoodColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
            border: Border.all(color: SnapFoodColors.softBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(SnapFoodSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Order #${order.id}',
                        style: SnapFoodTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: SnapFoodSpacing.sm),
                    SnapOrderStatus(status: order.status, compact: true),
                  ],
                ),
                const SizedBox(height: SnapFoodSpacing.sm),
                Text(
                  _statusMessage(order.status),
                  style: SnapFoodTypography.bodySmall.copyWith(color: SnapFoodColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ItemsSection extends StatelessWidget {
  const _ItemsSection({required this.items});
  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SnapFoodSpacing.md),
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                _OrderItemRow(item: items[index]),
                if (index < items.length - 1) const Divider(height: SnapFoodSpacing.lg),
              ],
              if (items.isEmpty)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No item details were returned for this order.',
                    style: TextStyle(fontSize: 13, color: SnapFoodColors.onSurfaceVariant),
                  ),
                ),
            ],
          ),
        ),
      );
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});
  final OrderItem item;

  String? _productName() {
    final product = item.payload['product'];
    if (product is Map && product['name'] != null) {
      final value = product['name'].toString().trim();
      if (value.isNotEmpty) return value;
    }
    for (final key in ['product_name', 'name']) {
      final value = item.payload[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  String? _lineTotal() {
    for (final key in ['line_total', 'subtotal', 'total']) {
      final value = item.payload[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final name = _productName() ?? 'Product #${item.productId}';
    final lineTotal = _lineTotal();

    return Semantics(
      container: true,
      label: '$name, quantity ${item.quantity}${lineTotal == null ? '' : ', $lineTotal rupees'}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SnapFoodTypography.bodyMedium.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: SnapFoodSpacing.xs),
                Text(
                  'Quantity ${item.quantity}',
                  style: SnapFoodTypography.bodySmall.copyWith(color: SnapFoodColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: SnapFoodSpacing.md),
          if (lineTotal != null)
            SnapPrice(value: lineTotal, fontSize: 15)
          else
            Text(
              '×${item.quantity}',
              style: SnapFoodTypography.labelLarge.copyWith(color: SnapFoodColors.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

class _DeliverySection extends StatelessWidget {
  const _DeliverySection({required this.address});
  final DeliveryAddress? address;

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return const _InfoSurface(
        child: Text(
          'Address snapshot unavailable.',
          style: TextStyle(fontSize: 13, color: SnapFoodColors.onSurfaceVariant),
        ),
      );
    }

    final parts = [
      address!.label,
      address!.recipientName,
      address!.addressLine1,
      if (address!.addressLine2?.trim().isNotEmpty == true) address!.addressLine2!,
      address!.city,
      address!.state,
      address!.postalCode,
      address!.country,
    ].where((part) => part.trim().isNotEmpty).toList();

    return _InfoSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parts.isEmpty ? 'Address snapshot unavailable.' : parts.first,
            style: SnapFoodTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
          ),
          if (parts.length > 1) ...[
            const SizedBox(height: SnapFoodSpacing.xs),
            Text(
              parts.skip(1).join(', '),
              style: SnapFoodTypography.bodySmall.copyWith(
                color: SnapFoodColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) => _InfoSurface(
        child: Column(
          children: [
            _DetailRow(
              label: 'Payment method',
              value: order.paymentMethod.isEmpty ? 'Not provided' : order.paymentMethod,
            ),
            const SizedBox(height: SnapFoodSpacing.sm),
            _DetailRow(
              label: 'Payment status',
              value: order.paymentStatus.isEmpty ? 'Not provided' : order.paymentStatus,
            ),
            const Divider(height: SnapFoodSpacing.lg),
            _DetailRow(label: 'Subtotal', value: order.subtotal, isPrice: true),
            const SizedBox(height: SnapFoodSpacing.sm),
            _DetailRow(label: 'Delivery', value: order.deliveryFee, isPrice: true),
            const Divider(height: SnapFoodSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total',
                    style: SnapFoodTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                if (order.total.isEmpty)
                  const Text(
                    'Amount unavailable',
                    style: TextStyle(fontSize: 13, color: SnapFoodColors.onSurfaceVariant),
                  )
                else
                  SnapPrice(value: order.total, fontSize: 20),
              ],
            ),
          ],
        ),
      );
}

class _TrackingPreview extends StatelessWidget {
  const _TrackingPreview({required this.tracking, required this.onRetry});
  final AsyncValue<OrderTracking?> tracking;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _InfoSurface(
        child: tracking.when(
          loading: () => const Row(
            children: [
              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: SnapFoodSpacing.sm),
              Expanded(child: Text('Loading live delivery status…')),
            ],
          ),
          error: (error, _) => SnapErrorState(
            title: 'Tracking unavailable',
            message: error.toString(),
            onRetry: onRetry,
          ),
          data: (value) {
            if (value == null) {
              return const Text(
                'Live tracking is not available yet.',
                style: TextStyle(fontSize: 13, color: SnapFoodColors.onSurfaceVariant),
              );
            }
            final location = value.latestLocation;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_searching_outlined,
                      color: SnapFoodColors.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: SnapFoodSpacing.sm),
                    Expanded(
                      child: Text(
                        value.status.isEmpty ? 'Delivery status unavailable' : value.status,
                        style: SnapFoodTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SnapFoodSpacing.xs),
                Text(
                  value.isStale
                      ? 'The latest location may be outdated.'
                      : location == null
                          ? 'Waiting for the latest delivery location.'
                          : 'Latest delivery location received.',
                  style: SnapFoodTypography.bodySmall.copyWith(color: SnapFoodColors.onSurfaceVariant),
                ),
              ],
            );
          },
        ),
      );
}

class _InfoSurface extends StatelessWidget {
  const _InfoSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SnapFoodSpacing.md),
          child: child,
        ),
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.isPrice = false});
  final String label;
  final String value;
  final bool isPrice;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: SnapFoodTypography.bodySmall.copyWith(color: SnapFoodColors.onSurfaceVariant),
            ),
          ),
          if (isPrice && value.isNotEmpty)
            SnapPrice(value: value, fontSize: 14)
          else
            Flexible(
              child: Text(
                value.isEmpty ? 'Not provided' : value,
                textAlign: TextAlign.end,
                style: SnapFoodTypography.bodySmall.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
        ],
      );
}

String _statusLabel(OrderStatus status) => switch (status) {
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

String _statusMessage(OrderStatus status) => switch (status) {
      OrderStatus.placed => 'Your order has been placed.',
      OrderStatus.accepted => 'Your order has been accepted.',
      OrderStatus.preparing => 'Your order is being prepared.',
      OrderStatus.readyForPickup => 'Your order is ready for pickup.',
      OrderStatus.assigned => 'A delivery partner has been assigned.',
      OrderStatus.pickedUp => 'Your order has been picked up.',
      OrderStatus.outForDelivery => 'Your order is on the way.',
      OrderStatus.delivered => 'This order has been delivered.',
      OrderStatus.cancelled => 'This order was cancelled.',
      OrderStatus.unknown => 'The current order status is unavailable.',
    };
