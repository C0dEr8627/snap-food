import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/snap_food_button.dart';
import '../../../design_system/components/snap_food_commerce.dart';
import '../../../design_system/components/snap_food_inputs.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_spacing.dart';
import 'catalogue_controller.dart';
import 'catalogue_state_message.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../data/catalogue_models.dart';
import '../data/cart_models.dart';
import 'cart_controller.dart';

class FoodItemDetailsScreen extends ConsumerStatefulWidget {
  const FoodItemDetailsScreen({super.key, required this.itemId});
  final String itemId;

  @override
  ConsumerState<FoodItemDetailsScreen> createState() =>
      _FoodItemDetailsScreenState();
}

class _FoodItemDetailsScreenState extends ConsumerState<FoodItemDetailsScreen> {
  int quantity = 1;

  CatalogueProduct? _findProduct(CatalogueSnapshot snapshot) {
    final id = int.tryParse(widget.itemId);
    if (id == null || id <= 0) return null;
    for (final product in snapshot.products.items) {
      if (product.id == id) return product;
    }
    return null;
  }

  void _addToCart(CatalogueProduct product) {
    final previewPrice = int.tryParse(product.price.split('.').first) ?? 0;
    ref
        .read(cartControllerProvider.notifier)
        .addItem(
          CartItem(
            productId: product.id.toString(),
            name: product.name,
            description: product.category?.name ?? 'Catalogue item',
            previewPrice: previewPrice,
            quantity: quantity,
            vegetarian:
                product.category?.name.toLowerCase().contains('veg') == true,
            imageUrl: product.imageUrl,
          ),
        );
    context.push('/cart');
  }

  @override
  Widget build(BuildContext context) {
    final catalogue = ref.watch(catalogueControllerProvider);
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        bottom: false,
        child: catalogue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(SnapFoodSpacing.mobileMargin),
            child: CatalogueStateMessage(
              value: catalogue,
              onRetry: () =>
                  ref.read(catalogueControllerProvider.notifier).retry(),
            ),
          ),
          data: (snapshot) {
            final product = _findProduct(snapshot);
            if (product == null) {
              return const Center(
                child: Text(
                  'This food item is not available in the current catalogue.',
                ),
              );
            }
            final previewPrice =
                int.tryParse(product.price.split('.').first) ?? 0;
            final vegetarian =
                product.category?.name.toLowerCase().contains('veg') == true;
            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: SnapFoodColors.surface,
                        surfaceTintColor: Colors.transparent,
                        leading: Semantics(
                          button: true,
                          label: 'Go back',
                          child: IconButton(
                            tooltip: 'Back',
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        title: const Text(
                          'Food Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(SnapFoodSpacing.mobileMargin, SnapFoodSpacing.sm, SnapFoodSpacing.mobileMargin, 0),
                          child: _FoodHero(
                            itemId: product.id.toString(),
                            vegetarian: vegetarian,
                            categoryName: product.category?.name,
                            imageUrl: product.imageUrl,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(SnapFoodSpacing.mobileMargin, SnapFoodSpacing.md + SnapFoodSpacing.xs, SnapFoodSpacing.mobileMargin, 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        height: 1.1,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: SnapFoodSpacing.sm),
                                  Text(
                                    '₹' + product.price,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: SnapFoodSpacing.sm,
                                runSpacing: SnapFoodSpacing.xs,
                                children: [
                                  _AvailabilityBadge(isAvailable: product.isAvailable),
                                  if (product.category?.name != null)
                                    SnapCategoryChip(
                                      label: product.category!.name,
                                      selected: false,
                                      onSelected: () {},
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Freshly prepared ' +
                                    product.name.toLowerCase() +
                                    ' from the current Snap Foodd catalogue.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: SnapFoodColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: SnapFoodSpacing.md),
                              const Divider(color: SnapFoodColors.softBorder),
                              const SizedBox(height: 16),
                              const Text(
                                'About this dish',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: SnapFoodSpacing.sm),
                              const Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _Tag(
                                    icon: Icons.eco_outlined,
                                    label: 'Catalogue verified',
                                  ),
                                  _Tag(
                                    icon: Icons.restaurant_outlined,
                                    label: 'Chef prepared',
                                  ),
                                  _Tag(
                                    icon: Icons.local_fire_department_outlined,
                                    label: 'Fresh',
                                  ),
                                ],
                              ),
                              const SizedBox(height: SnapFoodSpacing.lg),
                              const Text(
                                'The displayed price is a catalogue preview. The server remains authoritative during checkout.',
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(SnapFoodSpacing.mobileMargin, SnapFoodSpacing.sm, SnapFoodSpacing.mobileMargin, SnapFoodSpacing.md),
                    child: Row(
                      children: [
                        SnapQuantityStepper(
                          quantity: quantity,
                          onDecrement: quantity > 1
                              ? () => setState(() => quantity--)
                              : null,
                          onIncrement: quantity < 99
                              ? () => setState(() => quantity++)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SnapAddToCartButton(
                            enabled: product.isActive && product.isAvailable,
                            onPressed: () => _addToCart(product),
                            label: 'Add ' +
                                quantity.toString() +
                                (quantity == 1 ? ' item' : ' items') +
                                '  •  ₹' +
                                (previewPrice * quantity).toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FoodHero extends StatelessWidget {
  const _FoodHero({
    required this.itemId,
    required this.vegetarian,
    this.categoryName,
    this.imageUrl,
  });
  final String itemId;
  final bool vegetarian;
  final String? categoryName;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.45,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: vegetarian
                ? [SnapFoodColors.softYellow, SnapFoodColors.primaryContainer]
                : [SnapFoodColors.softRed, SnapFoodColors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: _FoodHeroImage(
                imageUrl: imageUrl,
                fallbackIcon: vegetarian ? Icons.eco : Icons.restaurant,
              ),
            ),
            Positioned(
              left: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: SnapFoodColors.surface.withAlpha(235),
                  borderRadius: BorderRadius.circular(SnapFoodRadii.full),
                ),
                child: Text(
                  categoryName ?? 'Catalogue',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.isAvailable});
  final bool isAvailable;

  @override
  Widget build(BuildContext context) => Semantics(
        label: isAvailable ? 'Available now' : 'Currently unavailable',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isAvailable ? SnapFoodColors.softYellow : SnapFoodColors.softRed,
            borderRadius: BorderRadius.circular(SnapFoodRadii.full),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SnapFoodSpacing.sm, vertical: SnapFoodSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isAvailable ? Icons.check_circle : Icons.remove_circle, size: 15, color: SnapFoodColors.secondary),
                const SizedBox(width: SnapFoodSpacing.xs),
                Text(isAvailable ? 'Available now' : 'Currently unavailable', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.full),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: SnapFoodColors.secondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _FoodHeroImage extends StatelessWidget {
  const _FoodHeroImage({
    required this.imageUrl,
    required this.fallbackIcon,
  });

  final String? imageUrl;
  final IconData fallbackIcon;

  bool get _hasRemoteImage {
    final value = imageUrl?.trim() ?? '';
    return value.startsWith('https://') || value.startsWith('http://');
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: SnapFoodColors.primaryContainer,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(42),
      child: SvgPicture.asset(
        'assets/images/customer/logo.svg',
        fit: BoxFit.contain,
      ),
    );

    if (!_hasRemoteImage) return fallback;

    return Image.network(
      imageUrl!.trim(),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
