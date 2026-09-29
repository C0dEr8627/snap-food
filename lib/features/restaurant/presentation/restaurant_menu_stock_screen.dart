import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class RestaurantMenuStockScreen extends StatefulWidget {
  const RestaurantMenuStockScreen({super.key});

  @override
  State<RestaurantMenuStockScreen> createState() => _RestaurantMenuStockScreenState();
}

class _RestaurantMenuStockScreenState extends State<RestaurantMenuStockScreen> {
  String _category = 'All';
  String _query = '';
  final Set<String> _unavailable = <String>{};

  static const items = <_MenuItem>[
    _MenuItem('Chicken Tikka Dum Biryani', 'Main Course', '₹320', 'In stock', '128 sold', Icons.rice_bowl),
    _MenuItem('Butter Chicken & 2 Naan', 'Main Course', '₹280', 'In stock', '96 sold', Icons.lunch_dining),
    _MenuItem('Paneer Butter Masala', 'Main Course', '₹240', 'Low stock', '74 sold', Icons.restaurant_menu),
    _MenuItem('Paneer Tikka', 'Starters', '₹210', 'In stock', '61 sold', Icons.kebab_dining),
    _MenuItem('Fish Fry', 'Starters', '₹260', 'Low stock', '42 sold', Icons.set_meal),
    _MenuItem('Garlic Naan', 'Breads', '₹70', 'In stock', '88 sold', Icons.bakery_dining),
    _MenuItem('Tandoori Roti', 'Breads', '₹35', 'In stock', '82 sold', Icons.flatware),
    _MenuItem('Masala Chaas', 'Beverages', '₹30', 'In stock', '53 sold', Icons.local_drink),
  ];

  List<_MenuItem> get visibleItems {
    final query = _query.trim().toLowerCase();
    return items.where((item) {
      final categoryOk = _category == 'All' || item.category == _category;
      final queryOk = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
      return categoryOk && queryOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 1024;
            return Row(
              children: [
                if (wide) const _Sidebar(),
                Expanded(
                  child: Column(
                    children: [
                      _Header(wide: wide),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(wide ? 24 : 16, 20, wide ? 24 : 16, 32),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: SnapFoodSpacing.desktopMaxContentWidth),
                              child: _Content(
                                category: _category,
                                query: _query,
                                items: visibleItems,
                                unavailable: _unavailable,
                                onQueryChanged: (value) => setState(() => _query = value),
                                onCategoryChanged: (value) => setState(() => _category = value),
                                onAvailabilityChanged: _setAvailability,
                                onEdit: _showEdit,
                                onAdd: _showAdd,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _setAvailability(String name, bool value) {
    setState(() {
      if (value) {
        _unavailable.remove(name);
      } else {
        _unavailable.add(name);
      }
    });
  }

  void _showAdd() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add item flow is ready for backend integration.')),
    );
  }

  void _showEdit(_MenuItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ' + item.name + ' is ready for backend integration.')),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.category,
    required this.query,
    required this.items,
    required this.unavailable,
    required this.onQueryChanged,
    required this.onCategoryChanged,
    required this.onAvailabilityChanged,
    required this.onEdit,
    required this.onAdd,
  });

  final String category;
  final String query;
  final List<_MenuItem> items;
  final Set<String> unavailable;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onCategoryChanged;
  final void Function(String, bool) onAvailabilityChanged;
  final ValueChanged<_MenuItem> onEdit;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Menu & Stock', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  SizedBox(height: 5),
                  Text('Manage menu items, pricing, and availability.',
                      style: TextStyle(fontSize: 13, color: SnapFoodColors.onSurfaceVariant)),
                ],
              ),
            ),
            if (wide)
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 17),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SnapFoodColors.primary,
                  foregroundColor: SnapFoodColors.warmBlack,
                  elevation: 0,
                ),
              )
            else
              IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle_outline_rounded)),
          ],
        ),
        const SizedBox(height: 20),
        const _Summary(),
        const SizedBox(height: 20),
        _Toolbar(
          category: category,
          query: query,
          onQueryChanged: onQueryChanged,
          onCategoryChanged: onCategoryChanged,
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const _Empty()
        else if (wide)
          _DesktopList(
            items: items,
            unavailable: unavailable,
            onAvailabilityChanged: onAvailabilityChanged,
            onEdit: onEdit,
          )
        else
          _MobileList(
            items: items,
            unavailable: unavailable,
            onAvailabilityChanged: onAvailabilityChanged,
            onEdit: onEdit,
          ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.category,
    required this.query,
    required this.onQueryChanged,
    required this.onCategoryChanged,
  });

  final String category;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    const categories = ['All', 'Starters', 'Main Course', 'Breads', 'Beverages'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search menu items',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => onQueryChanged(''),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
              filled: true,
              fillColor: SnapFoodColors.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final value in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(value),
                      selected: category == value,
                      onSelected: (_) => onCategoryChanged(value),
                      selectedColor: SnapFoodColors.primaryContainer,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) {
    const data = [
      ('Menu items', '24', Icons.restaurant_menu_rounded),
      ('Available', '18', Icons.check_circle_outline_rounded),
      ('Low stock', '4', Icons.inventory_2_outlined),
      ('Sold out', '2', Icons.remove_circle_outline_rounded),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final count = c.maxWidth >= 850 ? 4 : c.maxWidth >= 520 ? 2 : 1;
        final width = (c.maxWidth - (count - 1) * 12) / count;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in data)
              SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: SnapFoodColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
                    border: Border.all(color: SnapFoodColors.softBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: SnapFoodColors.softYellow,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.$3, size: 20, color: SnapFoodColors.warmBlack),
                      ),
                      const SizedBox(width: 11),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$1, style: const TextStyle(fontSize: 10, color: SnapFoodColors.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text(item.$2, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DesktopList extends StatelessWidget {
  const _DesktopList({
    required this.items,
    required this.unavailable,
    required this.onAvailabilityChanged,
    required this.onEdit,
  });

  final List<_MenuItem> items;
  final Set<String> unavailable;
  final void Function(String, bool) onAvailabilityChanged;
  final ValueChanged<_MenuItem> onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 13, 18, 11),
            child: Row(
              children: [
                SizedBox(width: 44),
                Expanded(flex: 4, child: Text('ITEM', style: _HeadStyle())),
                Expanded(flex: 2, child: Text('CATEGORY', style: _HeadStyle())),
                Expanded(flex: 2, child: Text('PRICE', style: _HeadStyle())),
                Expanded(flex: 2, child: Text('STOCK', style: _HeadStyle())),
                SizedBox(width: 82, child: Text('AVAILABLE', style: _HeadStyle())),
                SizedBox(width: 52, child: Text('ACTION', style: _HeadStyle())),
              ],
            ),
          ),
          for (final item in items)
            _DesktopRow(
              item: item,
              available: !unavailable.contains(item.name),
              onAvailabilityChanged: (value) => onAvailabilityChanged(item.name, value),
              onEdit: () => onEdit(item),
            ),
        ],
      ),
    );
  }
}

class _DesktopRow extends StatelessWidget {
  const _DesktopRow({
    required this.item,
    required this.available,
    required this.onAvailabilityChanged,
    required this.onEdit,
  });

  final _MenuItem item;
  final bool available;
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: SnapFoodColors.softBorder)),
      ),
      child: Row(
        children: [
          _ItemIcon(item: item),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(item.sold, style: const TextStyle(fontSize: 9, color: SnapFoodColors.onSurfaceVariant)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(item.category, style: const TextStyle(fontSize: 10))),
          Expanded(flex: 2, child: Text(item.price, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
          Expanded(flex: 2, child: _StockBadge(item.stock)),
          SizedBox(
            width: 82,
            child: Switch(
              value: available,
              onChanged: onAvailabilityChanged,
              activeColor: SnapFoodColors.primary,
            ),
          ),
          SizedBox(
            width: 52,
            child: IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: 'Edit item',
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileList extends StatelessWidget {
  const _MobileList({
    required this.items,
    required this.unavailable,
    required this.onAvailabilityChanged,
    required this.onEdit,
  });

  final List<_MenuItem> items;
  final Set<String> unavailable;
  final void Function(String, bool) onAvailabilityChanged;
  final ValueChanged<_MenuItem> onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MobileCard(
              item: item,
              available: !unavailable.contains(item.name),
              onAvailabilityChanged: (value) => onAvailabilityChanged(item.name, value),
              onEdit: () => onEdit(item),
            ),
          ),
      ],
    );
  }
}

class _MobileCard extends StatelessWidget {
  const _MobileCard({
    required this.item,
    required this.available,
    required this.onAvailabilityChanged,
    required this.onEdit,
  });

  final _MenuItem item;
  final bool available;
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ItemIcon(item: item, large: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.more_horiz_rounded, size: 19),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(item.category, style: const TextStyle(fontSize: 9, color: SnapFoodColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(item.price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 8),
                    _StockBadge(item.stock),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: Text(item.sold, style: const TextStyle(fontSize: 9, color: SnapFoodColors.onSurfaceVariant))),
                    Text(
                      available ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: available ? SnapFoodColors.primary : SnapFoodColors.secondary,
                      ),
                    ),
                    Switch(
                      value: available,
                      onChanged: onAvailabilityChanged,
                      activeColor: SnapFoodColors.primary,
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
}

class _ItemIcon extends StatelessWidget {
  const _ItemIcon({required this.item, this.large = false});

  final _MenuItem item;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: large ? 50 : 44,
      height: large ? 50 : 44,
      decoration: BoxDecoration(
        color: item.category == 'Starters' ? SnapFoodColors.softRed : SnapFoodColors.surfaceContainer,
        borderRadius: BorderRadius.circular(SnapFoodRadii.md),
      ),
      child: Icon(item.icon, size: large ? 23 : 21, color: SnapFoodColors.secondary),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge(this.stock);

  final String stock;

  @override
  Widget build(BuildContext context) {
    final low = stock == 'Low stock';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: low ? SnapFoodColors.softRed : SnapFoodColors.softYellow,
        borderRadius: BorderRadius.circular(SnapFoodRadii.full),
      ),
      child: Text(
        stock,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: low ? SnapFoodColors.secondary : SnapFoodColors.warmBlack,
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 38, color: SnapFoodColors.onSurfaceVariant),
          SizedBox(height: 10),
          Text('No menu items found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          SizedBox(height: 4),
          Text('Try another search or category.',
              style: TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        border: Border(right: BorderSide(color: SnapFoodColors.softBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(radius: 18, backgroundColor: SnapFoodColors.secondary, child: Icon(Icons.restaurant, color: Colors.white, size: 19)),
              SizedBox(width: 9),
              Text('SNAP FOODD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 32),
          _Nav('Dashboard', Icons.dashboard_rounded, () => context.go('/restaurant/dashboard')),
          _Nav('Live Orders / KDS', Icons.receipt_long_rounded, () => context.go('/restaurant/kds')),
          const _Nav('Menu & Stock', Icons.restaurant_menu_rounded),
          const _Nav('Analytics', Icons.analytics_outlined),
          const _Nav('Settings', Icons.settings_outlined),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: SnapFoodColors.softYellow, borderRadius: BorderRadius.circular(SnapFoodRadii.md)),
            child: const Row(
              children: [
                Icon(Icons.support_agent, size: 20, color: SnapFoodColors.primary),
                SizedBox(width: 8),
                Expanded(child: Text('Partner support\nAvailable 24×7', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav(this.label, this.icon, [this.onTap]);

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final child = Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(SnapFoodRadii.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: SnapFoodColors.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );

    return onTap == null
        ? child
        : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(SnapFoodRadii.md), child: child);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SnapFoodColors.surfaceContainerLowest,
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 16, vertical: 12),
        child: Row(
          children: [
            if (!wide)
              IconButton(
                onPressed: () => context.go('/restaurant/dashboard'),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Menu & Stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  if (wide)
                    const Text('Manage your menu and item availability',
                        style: TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(color: SnapFoodColors.softYellow, borderRadius: BorderRadius.circular(SnapFoodRadii.full)),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Color(0xFF2E7D32)),
                  SizedBox(width: 6),
                  Text('OPEN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 18,
              backgroundColor: SnapFoodColors.primaryContainer,
              child: Icon(Icons.storefront, size: 19, color: SnapFoodColors.warmBlack),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.name, this.category, this.price, this.stock, this.sold, this.icon);

  final String name;
  final String category;
  final String price;
  final String stock;
  final String sold;
  final IconData icon;
}

class _HeadStyle extends TextStyle {
  const _HeadStyle() : super(fontSize: 9, fontWeight: FontWeight.w900, color: SnapFoodColors.onSurfaceVariant, letterSpacing: 0.5);
}
