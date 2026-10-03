import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/snap_food_button.dart';
import '../../../design_system/components/snap_food_commerce.dart';
import '../../../design_system/components/snap_food_feedback.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../data/cart_models.dart';
import 'cart_controller.dart';

class CartReviewScreen extends ConsumerWidget {
  const CartReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final items = cart.items;
    final subtotal = cart.previewSubtotal;
    final itemCount = cart.itemCount;

    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1024;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: SnapFoodSpacing.desktopMaxContentWidth,
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: SnapFoodColors.surface,
                      surfaceTintColor: Colors.transparent,
                      leading: SnapIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        semanticLabel: 'Back',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      title: const Text(
                        'Your Cart',
                        style: SnapFoodTypography.titleLarge,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        wide ? SnapFoodSpacing.lg : SnapFoodSpacing.mobileMargin,
                        SnapFoodSpacing.sm,
                        wide ? SnapFoodSpacing.lg : SnapFoodSpacing.mobileMargin,
                        SnapFoodSpacing.xxl + SnapFoodSpacing.lg,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: items.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.only(top: SnapFoodSpacing.xl),
                                child: SnapEmptyState(
                                  icon: Icons.shopping_bag_outlined,
                                  title: 'Your cart is empty',
                                  message: 'Add a dish to start building your order.',
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SnapSectionHeader(
                                    title: '${itemCount} ${itemCount == 1 ? 'item' : 'items'} in your cart',
                                    subtitle: 'Review your dishes before checkout.',
                                    actionLabel: 'Add more',
                                    onAction: () => Navigator.of(context).pop(),
                                  ),
                                  const SizedBox(height: SnapFoodSpacing.md),
                                  ...items.map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: SnapFoodSpacing.sm,
                                      ),
                                      child: _CartItemCard(
                                        item: item,
                                        onRemove: () => ref
                                            .read(cartControllerProvider.notifier)
                                            .changeQuantity(item.productId, -1),
                                        onDelete: () => ref
                                            .read(cartControllerProvider.notifier)
                                            .removeItem(item.productId),
                                        onAdd: () => ref
                                            .read(cartControllerProvider.notifier)
                                            .changeQuantity(item.productId, 1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: SnapFoodSpacing.lg),
                                  _BillCard(itemTotal: subtotal),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SnapFoodSpacing.mobileMargin,
            SnapFoodSpacing.sm,
            SnapFoodSpacing.mobileMargin,
            SnapFoodSpacing.md,
          ),
          child: items.isEmpty
              ? SnapSecondaryButton(
                  label: 'Browse dishes',
                  icon: Icons.restaurant_menu_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                )
              : SnapPrimaryButton(
                  label: 'Continue to checkout',
                  icon: Icons.arrow_forward_rounded,
                  semanticLabel: 'Continue to checkout',
                  onPressed: () => context.push('/checkout'),
                ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onRemove,
    required this.onDelete,
    required this.onAdd,
  });

  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(SnapFoodSpacing.md),
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CartProductImage(item: item),
            const SizedBox(width: SnapFoodSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SnapFoodTypography.titleMedium,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Remove item'),
                      style: TextButton.styleFrom(foregroundColor: SnapFoodColors.error),
                    ),
                  ),
                  const SizedBox(height: SnapFoodSpacing.xs),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SnapFoodTypography.bodySmall.copyWith(
                      color: SnapFoodColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: SnapFoodSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SnapPrice(
                        value: item.previewPrice.toString(),
                        fontSize: 15,
                      ),
                      const Spacer(),
                      SnapQuantityStepper(
                        quantity: item.quantity,
                        onDecrement: onRemove,
                        onIncrement: onAdd,
                        compact: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _CartProductImage extends StatelessWidget {
  const _CartProductImage({required this.item});

  final CartItem item;

  bool get _hasRemoteImage {
    final value = item.imageUrl?.trim() ?? '';
    return value.startsWith('https://') || value.startsWith('http://');
  }

  @override
  Widget build(BuildContext context) {
    const size = 72.0;
    final fallback = ClipRRect(
      borderRadius: BorderRadius.circular(SnapFoodRadii.md),
      child: Container(
        width: size,
        height: size,
        color: SnapFoodColors.primaryContainer,
        padding: const EdgeInsets.all(SnapFoodSpacing.sm),
        child: SvgPicture.asset(
          'assets/images/customer/logo.svg',
          fit: BoxFit.contain,
        ),
      ),
    );

    if (!_hasRemoteImage) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(SnapFoodRadii.md),
      child: Image.network(
        item.imageUrl!.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  const _BillCard({required this.itemTotal});

  final int itemTotal;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(SnapFoodSpacing.md),
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bill details', style: SnapFoodTypography.titleMedium),
            const SizedBox(height: SnapFoodSpacing.md),
            _BillRow(
              label: 'Item total',
              child: SnapPrice(value: itemTotal.toString(), fontSize: 16),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: SnapFoodSpacing.md),
              child: Divider(color: SnapFoodColors.softBorder, height: 1),
            ),
            const _BillRow(
              label: 'Delivery fee & final charges',
              child: Text(
                'Calculated at checkout',
                style: SnapFoodTypography.labelMedium,
              ),
            ),
            const SizedBox(height: SnapFoodSpacing.sm),
            const DecoratedBox(
              decoration: BoxDecoration(
                color: SnapFoodColors.surfaceContainerLow,
                borderRadius: BorderRadius.all(
                  Radius.circular(SnapFoodRadii.md),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(SnapFoodSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: SnapFoodColors.secondary,
                      size: 18,
                    ),
                    SizedBox(width: SnapFoodSpacing.sm),
                    Expanded(
                      child: Text(
                        'The server recalculates the final order amount from the current catalogue at checkout.',
                        style: SnapFoodTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _BillRow extends StatelessWidget {
  const _BillRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: SnapFoodTypography.bodySmall.copyWith(
                color: SnapFoodColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: SnapFoodSpacing.sm),
          child,
        ],
      );
}
