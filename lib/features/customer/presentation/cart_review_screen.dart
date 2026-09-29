import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final deliveryFee = subtotal >= 299 ? 0 : 35;
    final taxes = ((subtotal + deliveryFee) * 0.05).round();
    final total = subtotal + deliveryFee + taxes;
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
                            const _RestaurantSummary(),
                            const SizedBox(height: 18),
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
                            if (items.isEmpty) const _EmptyCart(),
                            const SizedBox(height: 8),
                            const _InstructionCard(),
                            const SizedBox(height: 14),
                            const _CouponCard(),
                            const SizedBox(height: 20),
                            const Text(
                              'Bill details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _BillCard(
                              itemTotal: subtotal,
                              deliveryFee: deliveryFee,
                              taxes: taxes,
                              total: total,
                            ),
                            const SizedBox(height: 14),
                            const _DeliveryNote(),
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
                    'Review Order  •  ₹' + total.toString(),
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

class _RestaurantSummary extends StatelessWidget {
  const _RestaurantSummary();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: SnapFoodColors.primaryContainer,
            borderRadius: BorderRadius.circular(SnapFoodRadii.md),
          ),
          child: const Icon(
            Icons.restaurant,
            color: SnapFoodColors.secondary,
            size: 25,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mumbai Spice Kitchen',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 3),
              Text(
                'Andheri West  •  20–25 min',
                style: TextStyle(
                  fontSize: 10,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.verified, size: 17, color: SnapFoodColors.secondary),
      ],
    ),
  );
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
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: item.vegetarian
                ? SnapFoodColors.softYellow
                : SnapFoodColors.softRed,
            borderRadius: BorderRadius.circular(SnapFoodRadii.md),
          ),
          child: Icon(
            item.vegetarian ? Icons.eco : Icons.local_fire_department,
            color: item.vegetarian ? Colors.green : SnapFoodColors.secondary,
            size: 28,
          ),
        ),
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
                  Text(
                    '₹' + item.previewPrice.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  _MiniQuantity(
                    quantity: item.quantity,
                    onRemove: onRemove,
                    onAdd: onAdd,
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

class _MiniQuantity extends StatelessWidget {
  const _MiniQuantity({
    required this.quantity,
    required this.onRemove,
    required this.onAdd,
  });
  final int quantity;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    decoration: BoxDecoration(
      color: SnapFoodColors.secondary,
      borderRadius: BorderRadius.circular(SnapFoodRadii.full),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.remove, color: Colors.white, size: 14),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 30, minHeight: 32),
        ),
        Text(
          quantity.toString(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add, color: Colors.white, size: 14),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 30, minHeight: 32),
        ),
      ],
    ),
  );
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: const Row(
      children: [
        Icon(Icons.edit_note, color: SnapFoodColors.secondary, size: 21),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Add cooking instructions',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        Icon(Icons.chevron_right, size: 19, color: SnapFoodColors.outline),
      ],
    ),
  );
}

class _CouponCard extends StatelessWidget {
  const _CouponCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
    decoration: BoxDecoration(
      color: SnapFoodColors.softYellow,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
    ),
    child: Row(
      children: [
        const Icon(Icons.local_offer_outlined, color: SnapFoodColors.secondary),
        const SizedBox(width: 9),
        const Expanded(
          child: Text(
            'Apply a coupon',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'View offers',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

class _BillCard extends StatelessWidget {
  const _BillCard({
    required this.itemTotal,
    required this.deliveryFee,
    required this.taxes,
    required this.total,
  });
  final int itemTotal;
  final int deliveryFee;
  final int taxes;
  final int total;

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
        const SizedBox(height: 8),
        _BillRow(
          'Delivery fee',
          deliveryFee == 0 ? 'FREE' : '₹' + deliveryFee.toString(),
          accent: deliveryFee == 0,
        ),
        const SizedBox(height: 8),
        _BillRow('Taxes & charges', '₹' + taxes.toString()),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 11),
          child: Divider(color: SnapFoodColors.softBorder, height: 1),
        ),
        _BillRow('To pay', '₹' + total.toString(), strong: true),
      ],
    ),
  );
}

class _BillRow extends StatelessWidget {
  const _BillRow(
    this.label,
    this.value, {
    this.accent = false,
    this.strong = false,
  });
  final String label;
  final String value;
  final bool accent;
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
        value,
        style: TextStyle(
          fontSize: strong ? 15 : 11,
          fontWeight: FontWeight.w800,
          color: accent ? Colors.green : SnapFoodColors.onSurface,
        ),
      ),
    ],
  );
}

class _DeliveryNote extends StatelessWidget {
  const _DeliveryNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(SnapFoodRadii.md),
    ),
    child: const Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          color: SnapFoodColors.secondary,
          size: 19,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Delivering to Andheri West, Mumbai • Flat 402',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
    child: const Column(
      children: [
        Icon(
          Icons.shopping_bag_outlined,
          size: 42,
          color: SnapFoodColors.outline,
        ),
        SizedBox(height: 8),
        Text(
          'Your cart is empty',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
