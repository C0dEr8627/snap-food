import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import 'home_feed_screen.dart';
import 'order_controller.dart';
import '../data/order_models.dart';
import '../../../core/network/api_exception.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderHistoryControllerProvider);
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 76),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Text('Your Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    ),
                    Expanded(child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 44, color: SnapFoodColors.outline),
                const SizedBox(height: 12),
                const Text('We couldn’t load your orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  error is ApiException ? error.message : 'Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: SnapFoodColors.onSurfaceVariant, fontSize: 12),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.read(orderHistoryControllerProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (orders) {
          if (orders.orders.isEmpty)
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(orderHistoryControllerProvider.notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 92),
                children: const [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 52,
                    color: SnapFoodColors.outline,
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'No orders yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Your completed and active orders will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: SnapFoodColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            );
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(orderHistoryControllerProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
              itemCount: orders.orders.length + (orders.hasNextPage ? 1 : 0),
              separatorBuilder: (_, index) =>
                  SizedBox(height: index == orders.orders.length - 1 ? 0 : 12),
              itemBuilder: (context, index) {
                if (index == orders.orders.length)
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(orderHistoryControllerProvider.notifier)
                          .loadNextPage(),
                      child: const Text('Load more orders'),
                    ),
                  );
                final order = orders.orders[index];
                return _OrderCard(
                  orderId: order.id,
                  status: order.status,
                  paymentStatus: order.paymentStatus,
                  total: order.total,
                  itemCount: order.items.length,
                  onTap: () => context.push('/orders/' + order.id),
                );
              },
            ),
          );
                },
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(top: 0, left: 0, right: 0, child: HomeHeader()),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNav(selected: 2, onSelected: _noop),
            ),
          ],
        ),
      ),
    );
  }

  static void _noop(int _) {}
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.orderId,
    required this.status,
    required this.paymentStatus,
    required this.total,
    required this.itemCount,
    required this.onTap,
  });
  final String orderId;
  final OrderStatus status;
  final String paymentStatus;
  final String total;
  final int itemCount;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: SnapFoodColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: status == OrderStatus.delivered
                    ? SnapFoodColors.softRed
                    : SnapFoodColors.primaryContainer,
                borderRadius: BorderRadius.circular(SnapFoodRadii.md),
              ),
              child: Icon(
                status == OrderStatus.delivered
                    ? Icons.check_circle_outline
                    : Icons.delivery_dining,
                color: SnapFoodColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #' + orderId,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    itemCount.toString() +
                        ' item' +
                        (itemCount == 1 ? '' : 's') +
                        ' • ' +
                        _statusLabel(status),
                    style: const TextStyle(
                      fontSize: 11,
                      color: SnapFoodColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Payment: ' + (paymentStatus.isEmpty ? '—' : paymentStatus),
                    style: const TextStyle(
                      fontSize: 10,
                      color: SnapFoodColors.outline,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  total.isEmpty ? '—' : '₹' + total,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ],
        ),
      ),
    ),
  );
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
