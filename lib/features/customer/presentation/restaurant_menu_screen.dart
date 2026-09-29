import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import 'catalogue_controller.dart';
import 'catalogue_state_message.dart';
import '../../../design_system/tokens/app_radii.dart';

class RestaurantMenuScreen extends ConsumerStatefulWidget {
  const RestaurantMenuScreen({super.key});
  @override
  ConsumerState<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends ConsumerState<RestaurantMenuScreen> {
  int selectedCategory = 0;
  final quantities = <String, int>{'biryani': 1, 'butter': 1};

  void add(String id) => setState(() => quantities[id] = (quantities[id] ?? 0) + 1);
  void remove(String id) => setState(() {
    final q = quantities[id] ?? 0;
    if (q > 0) quantities[id] = q - 1;
  });

  @override
  Widget build(BuildContext context) {
    const categories = ['🔥 Best Sellers', 'Biryani & Rice', 'Tandoori & Starters', 'Curries & Breads', 'Beverages'];
    const items = [
      MenuItemData('Special Chicken Tikka Dum Biryani', 'Slow-cooked fragrant basmati rice with marinated chicken & aromatic saffron spice.', 320, 360, 'biryani', false, true),
      MenuItemData('Butter Chicken & 2 Butter Naan Combo', 'Boneless roasted chicken in creamy makhani gravy served with soft butter naans.', 280, null, 'butter', false),
      MenuItemData('Pure Veg Paneer Butter Masala & Kulcha', 'Fresh cottage cheese cubes in rich tomato cashew gravy.', 240, 280, 'paneer', true),
    ];
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          CustomScrollView(slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: SnapFoodColors.surface,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
              title: const Text('Restaurant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share)), IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border))],
            ),
            const SliverToBoxAdapter(child: _RestaurantHero()),
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
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Mumbai Spice Kitchen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('North Indian, Biryani & Mughlai • Andheri West', style: TextStyle(fontSize: 12, color: SnapFoodColors.onSurfaceVariant)),
                  ])),
                  _Verified(),
                ]),
                const SizedBox(height: 12),
                const Wrap(spacing: 8, runSpacing: 8, children: [
                  _InfoPill(Icons.star, '4.8  (1,250+ reviews)', true),
                  _InfoPill(Icons.schedule, '20–25 min'),
                  _InfoPill(Icons.near_me, '1.8 km'),
                  _InfoPill(Icons.currency_rupee, '₹₹'),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLow, borderRadius: BorderRadius.circular(SnapFoodRadii.md)),
                  child: const Row(children: [
                    Icon(Icons.two_wheeler, color: SnapFoodColors.secondary, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('₹35 delivery fee  •  Free delivery above ₹299', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                    Text('Open', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.green)),
                  ]),
                ),
              ]),
            )),
            SliverToBoxAdapter(child: SizedBox(height: 54, child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ChoiceChip(
                selected: selectedCategory == i,
                onSelected: (_) => setState(() => selectedCategory = i),
                showCheckmark: false,
                label: Text(categories[i], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                selectedColor: SnapFoodColors.primaryContainer,
                backgroundColor: SnapFoodColors.surfaceContainerLowest,
                side: BorderSide.none,
              ),
            ))),
            SliverToBoxAdapter(child: _MenuSection(title: '🔥 Best Sellers', subtitle: '3 crave-worthy picks', items: items, quantities: quantities, onAdd: add, onRemove: remove)),
            const SliverToBoxAdapter(child: _MenuSection(
              title: 'Tandoori & Starters',
              subtitle: 'Fresh Cut Daily',
              items: const [],
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ]),
          Positioned(left: 16, right: 16, bottom: 12, child: _CartBar(items: (quantities['biryani'] ?? 0) + (quantities['butter'] ?? 0), total: (quantities['biryani'] ?? 0) * 320 + (quantities['butter'] ?? 0) * 280)),
        ]),
      ),
    );
  }
}

class _RestaurantHero extends StatelessWidget {
  const _RestaurantHero();
  @override
  Widget build(BuildContext context) => Container(
    height: 150,
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [SnapFoodColors.primaryContainer, SnapFoodColors.accentYellow])),
    child: Stack(children: [
      Positioned(right: 20, top: 20, child: Icon(Icons.restaurant, size: 110, color: SnapFoodColors.warmBlack.withAlpha(28))),
      const Positioned(left: 16, bottom: 16, child: Row(children: [
        Icon(Icons.local_fire_department, color: SnapFoodColors.secondary, size: 22),
        SizedBox(width: 6),
        Text('Snappy 20m Dash!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
      ])),
    ]),
  );
}

class _Verified extends StatelessWidget {
  const _Verified();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: SnapFoodColors.softYellow,
      borderRadius: BorderRadius.circular(SnapFoodRadii.full),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.verified, size: 14, color: SnapFoodColors.secondary),
        SizedBox(width: 4),
        Text('Authentic', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class _InfoPill extends StatelessWidget {
  const _InfoPill(this.icon, this.text, [this.accent = false]);
  final IconData icon; final String text; final bool accent;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: accent ? SnapFoodColors.primaryContainer.withAlpha(90) : SnapFoodColors.surfaceContainer, borderRadius: BorderRadius.circular(SnapFoodRadii.full)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: accent ? SnapFoodColors.primary : SnapFoodColors.secondary), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))]),
  );
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.subtitle, required this.items, this.quantities = const {}, this.onAdd, this.onRemove});
  final String title, subtitle;
  final List<MenuItemData> items;
  final Map<String, int> quantities;
  final void Function(String)? onAdd, onRemove;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(subtitle, style: const TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
      const SizedBox(height: 10),
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _MenuItemCard(item: item, quantity: quantities[item.id] ?? 0, onAdd: onAdd == null ? () {} : () => onAdd!(item.id), onRemove: onRemove == null ? () {} : () => onRemove!(item.id)),
        ),
    ]),
  );
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item, required this.quantity, required this.onAdd, required this.onRemove});
  final MenuItemData item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: item.veg ? SnapFoodColors.softYellow : SnapFoodColors.softRed,
            borderRadius: BorderRadius.circular(SnapFoodRadii.md),
          ),
          child: Icon(item.veg ? Icons.eco : Icons.local_fire_department, color: item.veg ? Colors.green : SnapFoodColors.secondary, size: 32),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (item.veg) const Icon(Icons.circle, size: 10, color: Colors.green),
            if (item.veg) const SizedBox(width: 4),
            Expanded(child: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))),
            if (item.bestseller)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(color: SnapFoodColors.softRed, borderRadius: BorderRadius.circular(5)),
                child: const Text('Bestseller', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: SnapFoodColors.secondary)),
              ),
          ]),
          const SizedBox(height: 5),
          Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, height: 1.35, color: SnapFoodColors.onSurfaceVariant)),
          const SizedBox(height: 7),
          Row(children: [
            Text('₹' + item.price.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            if (item.oldPrice != null) ...[
              const SizedBox(width: 5),
              Text('₹' + item.oldPrice.toString(), style: const TextStyle(fontSize: 10, decoration: TextDecoration.lineThrough, color: SnapFoodColors.outline)),
            ],
            const Spacer(),
            if (quantity == 0)
              OutlinedButton(
                onPressed: onAdd,
                style: OutlinedButton.styleFrom(foregroundColor: SnapFoodColors.secondary, side: const BorderSide(color: SnapFoodColors.secondary), padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7)),
                child: const Text('ADD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              )
            else
              Container(
                decoration: BoxDecoration(color: SnapFoodColors.secondary, borderRadius: BorderRadius.circular(SnapFoodRadii.full)),
                child: Row(children: [
                  IconButton(onPressed: onRemove, icon: const Icon(Icons.remove, color: Colors.white, size: 15), constraints: const BoxConstraints(minWidth: 30, minHeight: 30), padding: EdgeInsets.zero),
                  Text(quantity.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                  IconButton(onPressed: onAdd, icon: const Icon(Icons.add, color: Colors.white, size: 15), constraints: const BoxConstraints(minWidth: 30, minHeight: 30), padding: EdgeInsets.zero),
                ]),
              ),
          ]),
        ])),
      ]),
    ),
  );
}

class _CartBar extends StatelessWidget {
  const _CartBar({required this.items, required this.total, required this.onTap});
  final int items, total;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: SnapFoodColors.secondary, borderRadius: BorderRadius.circular(SnapFoodRadii.lg), elevation: 8,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          const Icon(Icons.shopping_bag, color: Colors.white, size: 20), const SizedBox(width: 8),
          Expanded(child: Text(items.toString() + ' items selected  •  ₹' + total.toString() + ' + taxes', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white))),
          const Text('View Cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)), const SizedBox(width: 5), const Icon(Icons.arrow_forward, color: Colors.white, size: 17),
        ]),
      ),
    ),
  );
}

class MenuItemData {
  const MenuItemData(this.name, this.description, this.price, this.oldPrice, this.id, this.veg, [this.bestseller = false]);
  final String name, description, id;
  final int price;
  final int? oldPrice;
  final bool veg, bestseller;
}
