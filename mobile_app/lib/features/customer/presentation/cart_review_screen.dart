import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/snap_food_commerce.dart';
import '../../../design_system/components/snap_food_feedback.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';
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
                      leading: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      title: const Text(
                        'Your Cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        wide ? 24 : 16,
                        8,
                        wide ? 24 : 16,
                        120,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    itemCount.toString() +
                                        ' items in your cart',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text(
                                    'Add more',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: SnapFoodColors.secondary,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _CartItemCard(
                                  item: item,
                                  onRemove: () => ref
                                      .read(cartControllerProvider.notifier)
                                      .changeQuantity(item.productId, -1),
                                  onAdd: () => ref
                                      .read(cartControllerProvider.notifier)
                                      .changeQuantity(item.productId, 1),
                                ),
                              ),
                            ),
                            if (items.isEmpty) const SnapEmptyState(
                              icon: Icons.shopping_bag_outlined,
                              title: 'Your cart is empty',
                              message: 'Add a dish to start building your order.',
                            ),
                            if (items.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              const Text(
                                'Bill details',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 10),
                              _BillCard(itemTotal: subtotal),
                              const SizedBox(height: 12),
                              const _CheckoutPricingNote(),
                            ],
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: items.isEmpty ? null : () => context.push('/checkout'),
            style: FilledButton.styleFrom(
              backgroundColor: SnapFoodColors.secondary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SnapFoodRadii.md),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Continue to checkout',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 19),
              ],
            ),
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
    required this.onAdd,
  });
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CartProductImage(item: item),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 10,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SnapPrice(
                    value: item.previewPrice.toString(),
                    fontSize: 12,
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
    const size = 62.0;
    final fallback = ClipRRect(
      borderRadius: BorderRadius.circular(SnapFoodRadii.md),
      child: Container(
        width: size,
        height: size,
        color: SnapFoodColors.primaryContainer,
        padding: const EdgeInsets.all(10),
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
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: Column(
      children: [
        _BillRow('Item total', '₹' + itemTotal.toString()),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 11),
          child: Divider(color: SnapFoodColors.softBorder, height: 1),
        ),
        const Row(
          children: [
            Expanded(
              child: Text(
                'Delivery fee & final charges',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SnapFoodColors.onSurfaceVariant),
              ),
            ),
            Text(
              'Calculated at checkout',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ],
    ),
  );
}

class _BillRow extends StatelessWidget {
  const _BillRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SnapFoodColors.onSurfaceVariant))),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
    ],
  );
}

class _CheckoutPricingNote extends StatelessWidget {
  const _CheckoutPricingNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(SnapFoodRadii.md),
    ),
    child: const Row(
      children: [
        Icon(Icons.receipt_long_outlined, color: SnapFoodColors.secondary, size: 19),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'The server recalculates the final order amount from the current catalogue at checkout.',
            style: TextStyle(fontSize: 10, fontWeight\n          ),\n        ),\n      ],\n    ),\n  );\n}\n