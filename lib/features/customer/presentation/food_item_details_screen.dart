import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import 'catalogue_controller.dart';
import 'catalogue_state_message.dart';
import '../../../design_system/tokens/app_radii.dart';

class FoodItemDetailsScreen extends ConsumerStatefulWidget {
  const FoodItemDetailsScreen({super.key, this.itemId = 'biryani'});
  final String itemId;

  @override
  ConsumerState<FoodItemDetailsScreen> createState() => _FoodItemDetailsScreenState();
}

class _FoodItemDetailsScreenState extends ConsumerState<FoodItemDetailsScreen> {
  int quantity = 1;

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
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: SnapFoodColors.surface,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
              title: const Text('Food Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _FoodHero(itemId: widget.itemId),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer(builder: (context, ref, _) {
                final catalogue = ref.watch(catalogueControllerProvider);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: CatalogueStateMessage(
                    value: catalogue,
                    onRetry: () => ref.read(catalogueControllerProvider.notifier).retry(),
                  ),
                );
              }),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(color: SnapFoodColors.softRed, borderRadius: BorderRadius.circular(SnapFoodRadii.full)),
                          child: const Text('BESTSELLER', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: SnapFoodColors.secondary)),
                        ),
                        const SizedBox(height: 8),
                        Text(itemName, style: const TextStyle(fontSize: 24, height: 1.1, fontWeight: FontWeight.w800)),
                      ])),
                      const SizedBox(width: 12),
                      Text('₹' + price.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 10),
                    const Row(children: [
                      Icon(Icons.star, size: 17, color: SnapFoodColors.primary),
                      SizedBox(width: 4),
                      Text('4.8', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      SizedBox(width: 4),
                      Text('(320 ratings)', style: TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
                      SizedBox(width: 10),
                      Text('•', style: TextStyle(color: SnapFoodColors.outline)),
                      SizedBox(width: 10),
                      Text('20–25 min', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 16),
                    Text(description, style: const TextStyle(fontSize: 13, height: 1.5, color: SnapFoodColors.onSurfaceVariant)),
                    const SizedBox(height: 18),
                    const Divider(color: SnapFoodColors.softBorder),
                    const SizedBox(height: 16),
                    const Text('About this dish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    const Wrap(spacing: 8, runSpacing: 8, children: [
                      _Tag(icon: Icons.eco_outlined, label: 'Fresh ingredients'),
                      _Tag(icon: Icons.restaurant_outlined, label: 'Chef prepared'),
                      _Tag(icon: Icons.local_fire_department_outlined, label: 'Serves 1'),
                    ]),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLow, borderRadius: BorderRadius.circular(SnapFoodRadii.lg)),
                      child: const Row(children: [
                        Icon(Icons.info_outline, size: 19, color: SnapFoodColors.secondary),
                        SizedBox(width: 10),
                        Expanded(child: Text('Prices and availability may vary during peak hours.', style: TextStyle(fontSize: 11, height: 1.4, fontWeight: FontWeight.w600))),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(children: [
            _QuantityControl(
              quantity: quantity,
              onRemove: quantity > 1 ? () => setState(() => quantity--) : null,
              onAdd: () => setState(() => quantity++),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => context.push('/cart'),
                style: FilledButton.styleFrom(
                  backgroundColor: SnapFoodColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SnapFoodRadii.md)),
                ),
                child: Text(
                  'Add ' + quantity.toString() + (quantity == 1 ? ' item' : ' items') + '  •  ₹' + (price * quantity).toString(),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _FoodHero extends StatelessWidget {
  const _FoodHero({required this.itemId});
  final String itemId;

  @override
  Widget build(BuildContext context) {
    final veg = itemId == 'paneer';
    return AspectRatio(
      aspectRatio: 1.45,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: veg ? [SnapFoodColors.softYellow, SnapFoodColors.primaryContainer] : [SnapFoodColors.softRed, SnapFoodColors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
        ),
        child: Stack(children: [
          Center(child: Icon(veg ? Icons.eco : Icons.restaurant, size: 110, color: veg ? Colors.green.withAlpha(100) : SnapFoodColors.secondary.withAlpha(80))),
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(color: SnapFoodColors.surface.withAlpha(235), borderRadius: BorderRadius.circular(SnapFoodRadii.full)),
              child: const Text('Mumbai Spice Kitchen', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
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
  final VoidCallback onAdd;

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
