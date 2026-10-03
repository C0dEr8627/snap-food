import 'package:flutter/material.dart';

import '../../features/customer/data/order_models.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class SnapOrderStatus extends StatelessWidget {
  const SnapOrderStatus({
    required this.status,
    this.compact = false,
    super.key,
  });

  final OrderStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tone = _tone(status);
    final label = _label(status);

    return Semantics(
      label: 'Order status: $label',
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tone.background,
          borderRadius: BorderRadius.circular(SnapFoodRadii.full),
          border: Border.all(color: tone.foreground.withAlpha(70)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? SnapFoodSpacing.sm : SnapFoodSpacing.md,
            vertical: SnapFoodSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tone.icon,
                size: compact ? 13 : 14,
                color: tone.foreground,
              ),
              const SizedBox(width: SnapFoodSpacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SnapFoodTypography.labelSmall.copyWith(
                  color: tone.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _OrderStatusTone _tone(OrderStatus status) => switch (status) {
        OrderStatus.placed || OrderStatus.accepted => const _OrderStatusTone(
            background: SnapFoodColors.softYellow,
            foreground: SnapFoodColors.warmBlack,
            icon: Icons.receipt_long_outlined,
          ),
        OrderStatus.preparing ||
        OrderStatus.readyForPickup ||
        OrderStatus.assigned ||
        OrderStatus.pickedUp ||
        OrderStatus.outForDelivery =>
          const _OrderStatusTone(
            background: SnapFoodColors.softYellow,
            foreground: SnapFoodColors.secondary,
            icon: Icons.delivery_dining_outlined,
          ),
        OrderStatus.delivered => const _OrderStatusTone(
            background: SnapFoodColors.softRed,
            foreground: SnapFoodColors.secondary,
            icon: Icons.check_circle_outline,
          ),
        OrderStatus.cancelled => const _OrderStatusTone(
            background: SnapFoodColors.softRed,
            foreground: SnapFoodColors.warmBlack,
            icon: Icons.cancel_outlined,
          ),
        OrderStatus.unknown => const _OrderStatusTone(
            background: SnapFoodColors.surfaceContainer,
            foreground: SnapFoodColors.onSurfaceVariant,
            icon: Icons.help_outline_rounded,
          ),
      };

  static String _label(OrderStatus status) => switch (status) {
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

class _OrderStatusTone {
  const _OrderStatusTone({
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
}
