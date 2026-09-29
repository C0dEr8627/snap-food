import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
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
  ConsumerState<FoodItemDetailsScreen> createState() => _FoodItemDetailsScreenState();
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
    ref.read(cartControllerProvider.notifier).addItem(
      CartItem(
        productId: product.id.toString(),
        name: product.name,
        description: product.category?.name ?? 'Catalogue item',
        previewPrice: previewPrice,
        quantity: quantity,
        vegetarian: product.category?.name.toLowerCase().contains('veg') == true,
      ),
    );
    context.push('/cart');
  }

  String get itemName => widget.itemId == 'butter'
      ? 'Butter Chicken & 2 Butter Naan Combo'
      : widget.itemId == 'paneer'
          ? 'Pure Veg Paneer Butter Masala & Kulcha'
          : 'Special Chicken Tikka Dum Biryani';

  String get description => widget.itemId == 'butter'
      ? 'Boneless roasted chicken in creamy makhani gravy served with soft butter naans.'
      : widget.itemId == 'paneer'
          ? 'Fresh cottage cheese cubes in rich tomato cashew gravy, served with warm kulcha.'
          : 'Slow-cooked fragrant basmati rice with marinated chicken, aromatic saffron and whole spices.';

  int get price => widget.itemId == 'butter' ? 280 : widget.itemId == 'paneer' ? 240 : 320;

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
            padding: const EdgeInsets.all(16),
            child: CatalogueStateMessage(
              value: catalogue,
              onRetry: () => ref.read(catalogueControllerProvider.notifier).retry(),
            ),
          ),
          data: (snapshot) {
            final product = _findProduct(snapshot);
            if (product == null) {
              return const Center(
                child: Text('This food item is not available in the current catalogue.'),
              );
            }
            final previewPrice = int.tryParse(product.price.split('.').first) ?? 0;
            final vegetarian = product.category?.name.toLowerCase().contains('veg') == true;
            return Column(
              children: [
                Expanded(
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
                        title: const Text('Food Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: _FoodHero(itemId: product.id.toString(), vegetarian: vegetarian, categoryName: product.category?.name),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Expanded(child: Text(product.name, style: const TextStyle(fontSize: 24, height: 1.1, fontWeight: FontWeight.w800))),
                                const SizedBox(width: 12),
                                Text('₹' + product.price, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                Icon(product.isAvailable ? Icons.check_circle : Icons.remove_circle, size: 17, color: product.isAvailable ? Colors.green : SnapFoodColors.secondary),
                                const SizedBox(width: 5),
                                Text(product.isAvailable ? 'Available now' : 'Currently unavailable', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                const SizedBox(width: 12),
                                Text(product.category?.name ?? 'Food', style: const TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
                              ]),
                              const SizedBox(height: 16),
                              Text(
                                'Freshly prepared ' + product.name.toLowerCase() + ' from the current Snap Foodd catalogue.',
                                style: const TextStyle(fontSize: 13, height: 1.5, color: SnapFoodColors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 18),
                              const Divider(color: SnapFoodColors.softBorder),
                              const SizedBox(height: 16),
                              const Text('About this dish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 10),
                              const Wrap(spacing: 8, runSpacing: 8, children: [
                                _Tag(icon: Icons.eco_outlined, label: 'Catalogue verified'),
                                _Tag(icon: Icons.restaurant_outlined, label: 'Chef prepared'),
                                _Tag(icon: Icons.local_fire_department_outlined, label: 'Fresh'),
                              ]),
                              const SizedBox(height: 24),
                              const Text(
                                'The displayed price is a catalogue preview. The server remains authoritative during checkout.',
                                style: TextStyle(fontSize: 11, height: 1.4, fontWeight: FontWeight.w600),
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(children: [
                      _QuantityControl(
                        quantity: quantity,
                        onRemove: quantity > 1 ? () => setState(() => quantity--) : null,
                        onAdd: quantity < 99 ? () => setState(() => quantity++) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: product.isActive && product.isAvailable ? () => _addToCart(product) : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: SnapFoodColors.secondary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SnapFoodRadii.md)),
                          ),
                          child: Text(
                            'Add ' + quantity.toString() + (quantity == 1 ? ' item' : ' items') + '  •  ₹' + (previewPrice * quantity).toString(),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ]),
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
  const _FoodHero({required this.itemId, required this.vegetarian, this.categoryName});
  final String itemId;
  final bool vegetarian;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.45,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: vegetarian ? [SnapFoodColors.softYellow, SnapFoodColors.primaryContainer] : [SnapFoodColors.softRed, SnapFoodColors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
        ),
        child: Stack(children: [
          Center(child: Icon(vegetarian ? Icons.eco : Icons.restaurant, size: 110, color: vegetarian ? Colors.green.withAlpha(100) : SnapFoodColors.secondary.withAlpha(80))),
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(color: SnapFoodColors.surface.withAlpha(235), borderRadius: BorderRadius.circular(SnapFoodRadii.full)),
              child: Text(categoryName ?? 'Catalogue', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(SnapFoodRadii.full), border: Border.all(color: SnapFoodColors.softBorder)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15, color: SnapFoodColors.secondary),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.quantity, required this.onRemove, required this.onAdd});
  final int quantity;
  final VoidCallback? onRemove;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(SnapFoodRadii.md), border: Border.all(color: SnapFoodColors.softBorder)),
    child: Row(children: [
      IconButton(onPressed: onRemove, icon: const Icon(Icons.remove, size: 17)),
      Text(quantity.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
      IconButton(onPressed: onAdd, icon: const Icon(Icons.add, size: 17)),
    ]),
  );
}
