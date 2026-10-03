import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import 'home_feed_screen.dart';
import 'order_controller.dart';
import '../data/order_models.dart';
import '../../../core/network/api_exception.dart';
import '../../../design_system/components/snap_food_button.dart';
import '../../../design_system/components/snap_food_commerce.dart';
import '../../../design_system/components/snap_food_feedback.dart';
import '../../../design_system/components/snap_order_status.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_typography.dart';

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
                      padding: EdgeInsets.fromLTRB(
                        SnapFoodSpacing.mobileMargin,
                        SnapFoodSpacing.xs,
                        SnapFoodSpacing.mobileMargin,
                        SnapFoodSpacing.md,
                      ),
                      child: Text(
                        'Your Orders',
                        style: SnapFoodTypography.headlineSmall,
                      ),
                    ),
                    Expanded(
                      child: state.when(
                        loading: () => const SnapLoadingState(
                          message: 'Loading your orders…',
                        ),
                        error: (error, _) => SnapErrorState(
                          title: 'We couldn’t load your orders',
                          message: error is ApiException
                              ? error.message
                              : 'Check your connection and try again.',
                          onRetry: () => ref
                              .read(orderHistoryControllerProvider.notifier)
                              .refresh(),
                        ),
                        data: (orders) {
                          if (orders.orders.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: () => ref
                                  .read(orderHistoryControllerProvider.notifier)
                                  .refresh(),
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  SnapFoodSpacing.mobileMargin,
                                  SnapFoodSpacing.xxl,
                                  SnapFoodSpacing.mobileMargin,
                                  104,
                                ),
                                children: const [
                                  SnapEmptyState(
                                    title: 'No orders yet',
                                    message:
                                        'Your active and past orders will appear here after you place your first order.',
                                    icon: Icons.receipt_long_outlined,
                                  ),
                                ],
                              ),
                            );
                          }

                          final active = orders.orders
                              .where(_isActiveOrder)
                              .toList(growable: false);
                          final past = orders.orders
                              .where((order) => !_isActiveOrder(order))
                              .toList(growable: false);

                          return RefreshIndicator(
                            onRefresh: () => ref
                                .read(orderHistoryControllerProvider.notifier)
                                .refresh(),
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                SnapFoodSpacing.mobileMargin,
                                SnapFoodSpacing.xs,
                                SnapFoodSpacing.mobileMargin,
                                104,
                              ),
                              children: [
                                if (active.isNotEmpty) ...[
                                  _OrderSectionHeader(
                                    title: 'Active orders',
                                    count: active.length,
                                  ),
                                  const SizedBox(height: SnapFoodSpacing.sm),
                                  for (final order in active) ...[
                                    _OrderCard(
                                      order: order,
                                      onTap: () => context.push('/orders/' + order.id),
                                    ),
                                    const SizedBox(height: SnapFoodSpacing.sm),
                                  ],
                                ],
                                if (past.isNotEmpty) ...[
                                  _OrderSectionHeader(
                                    title: 'Past orders',
                                    count: past.length,
                                  ),
                                  const SizedBox(height: SnapFoodSpacing.sm),
                                  for (final order in past) ...[
                                    _OrderCard(
                                      order: order,
                                      onTap: () => context.push('/orders/' + order.id),
                                    ),
                                    const SizedBox(height: SnapFoodSpacing.sm),
                                  ],
                                ],
                                if (orders.hasNextPage) ...[
                                  const SizedBox(height: SnapFoodSpacing.xs),
                                  SnapSecondaryButton(
                                    label: 'Load more orders',
                                    onPressed: () => ref
                                        .read(orderHistoryControllerProvider.notifier)
                                        .loadNextPage(),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
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

  static bool _isActiveOrder(Order order) => switch (order.status) {
        OrderStatus.placed ||
        OrderStatus.accepted ||
        OrderStatus.preparing ||
        OrderStatus.readyForPickup ||
        OrderStatus.assigned ||
        OrderStatus.pickedUp ||
        OrderStatus.outForDelivery => true,
        OrderStatus.delivered ||
        OrderStatus.cancelled ||
        OrderStatus.unknown => false,
      };

  static void _noop(int _) {}
}

class _OrderSectionHeader extends StatelessWidget {
  const _OrderSectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: SnapFoodTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: SnapFoodTypography.labelMedium.copyWith(
              color: SnapFoodColors.onSurfaceVariant,
            ),
          ),
        ],
      );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemCount = order.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final itemLabel = itemCount == 1 ? '1 item' : itemCount.toString() + ' items';

    return Semantics(
      button: true,
      container: true,
      label: 'Order #' + order.id + ', ' + _statusLabel(order.status) +
          ', ' + itemLabel + ', total ' + _priceLabel(order.total),
      child: Material(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          child: Padding(
            padding: const EdgeInsets.all(SnapFoodSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Order #' + order.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SnapFoodTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: SnapFoodSpacing.sm),
                    SnapOrderStatus(status: order.status),
                  ],
                ),
                const SizedBox(height: SnapFoodSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        itemLabel,
                        style: SnapFoodTypography.bodySmall.copyWith(
                          color: SnapFoodColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SnapPrice(value: order.total, fontSize: 16),
                    const SizedBox(width: SnapFoodSpacing.sm),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: SnapFoodColors.outline,
                    ),
                  ],
                ),
                if (order.paymentStatus.isNotEmpty) ...[
                  const SizedBox(height: SnapFoodSpacing.sm),
                  Text(
                    'Payment: ' + order.paymentStatus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SnapFoodTypography.labelSmall.copyWith(
                      color: SnapFoodColors.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _priceLabel(String value) =>
      value.isEmpty ? 'amount unavailable' : '₹' + value;

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
