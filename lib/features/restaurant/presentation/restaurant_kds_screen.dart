import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class RestaurantKdsScreen extends StatefulWidget {
  const RestaurantKdsScreen({super.key});

  @override
  State<RestaurantKdsScreen> createState() => _RestaurantKdsScreenState();
}

class _RestaurantKdsScreenState extends State<RestaurantKdsScreen> {
  String _filter = 'All';

  static const _orders = [
    _KdsOrder(
      id: 'SF10248',
      time: '2 min ago',
      customer: 'Aarav Mehta',
      status: 'Preparing',
      items: [
        _KdsItem(name: 'Chicken Tikka Dum Biryani', quantity: 1),
        _KdsItem(name: 'Butter Chicken & 2 Naan', quantity: 1),
      ],
      total: '₹630',
    ),
    _KdsOrder(
      id: 'SF10247',
      time: '8 min ago',
      customer: 'Isha Shah',
      status: 'Ready',
      items: [
        _KdsItem(name: 'Paneer Butter Masala', quantity: 1),
        _KdsItem(name: 'Garlic Naan', quantity: 2),
        _KdsItem(name: 'Masala Chaas', quantity: 1),
      ],
      total: '₹540',
    ),
    _KdsOrder(
      id: 'SF10246',
      time: '1 min ago',
      customer: 'Rohan Patil',
      status: 'New',
      items: [
        _KdsItem(name: 'Chicken Tikka Dum Biryani', quantity: 1),
      ],
      total: '₹320',
    ),
    _KdsOrder(
      id: 'SF10245',
      time: '14 min ago',
      customer: 'Neha Kulkarni',
      status: 'Preparing',
      items: [
        _KdsItem(name: 'Butter Chicken & 2 Naan', quantity: 1),
        _KdsItem(name: 'Paneer Tikka', quantity: 1),
      ],
      total: '₹490',
    ),
    _KdsOrder(
      id: 'SF10244',
      time: '18 min ago',
      customer: 'Kabir Joshi',
      status: 'Ready',
      items: [
        _KdsItem(name: 'Paneer Butter Masala', quantity: 1),
        _KdsItem(name: 'Tandoori Roti', quantity: 3),
      ],
      total: '₹410',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1024;

            return Row(
              children: [
                if (wide) const _KdsSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      _KdsHeader(wide: wide),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            wide ? 24 : 16,
                            20,
                            wide ? 24 : 16,
                            32,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: SnapFoodSpacing.desktopMaxContentWidth,
                              ),
                              child: _KdsContent(
                                orders: _orders,
                                filter: _filter,
                                onFilterChanged: (value) {
                                  setState(() => _filter = value);
                                },
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
}

class _KdsContent extends StatelessWidget {
  const _KdsContent({
    required this.orders,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<_KdsOrder> orders;
  final String filter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final visibleOrders = filter == 'All'
        ? orders
        : orders.where((order) => order.status == filter).toList();

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
                  Text(
                    'Live Orders / KDS',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Manage incoming orders and kitchen preparation.',
                    style: TextStyle(
                      fontSize: 13,
                      color: SnapFoodColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.volume_up_outlined, size: 15),
              label: const Text('Kitchen Sound'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _KdsSummary(orders: orders),
        const SizedBox(height: 20),
        _KdsFilters(selected: filter, onChanged: onFilterChanged),
        const SizedBox(height: 16),
        if (visibleOrders.isEmpty)
          const _KdsEmptyState()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 560
                      ? 2
                      : 1;
              const gap = 14.0;
              final width =
                  (constraints.maxWidth - (columns - 1) * gap) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final order in visibleOrders)
                    SizedBox(
                      width: width,
                      child: _KdsOrderCard(order: order),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _KdsSummary extends StatelessWidget {
  const _KdsSummary({required this.orders});

  final List<_KdsOrder> orders;

  @override
  Widget build(BuildContext context) {
    final newCount = orders.where((order) => order.status == 'New').length;
    final preparingCount =
        orders.where((order) => order.status == 'Preparing').length;
    final readyCount = orders.where((order) => order.status == 'Ready').length;

    return Row(
      children: [
        Expanded(child: _SummaryTile(label: 'New', value: newCount.toString())),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'Preparing',
            value: preparingCount.toString(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(label: 'Ready', value: readyCount.toString()),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(label: 'Total', value: orders.length.toString()),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.md),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: SnapFoodColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _KdsFilters extends StatelessWidget {
  const _KdsFilters({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  static const filters = ['All', 'New', 'Preparing', 'Ready'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters) ...[
            if (filter != filters.first) const SizedBox(width: 8),
            ChoiceChip(
              label: Text(filter),
              selected: selected == filter,
              onSelected: (_) => onChanged(filter),
              selectedColor: SnapFoodColors.primaryContainer,
              backgroundColor: SnapFoodColors.surfaceContainerLowest,
              side: const BorderSide(color: SnapFoodColors.softBorder),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: selected == filter
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: SnapFoodColors.warmBlack,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KdsOrderCard extends StatelessWidget {
  const _KdsOrderCard({required this.order});

  final _KdsOrder order;

  Color _statusColor() {
    switch (order.status) {
      case 'New':
        return SnapFoodColors.softYellow;
      case 'Preparing':
        return SnapFoodColors.softRed;
      case 'Ready':
        return SnapFoodColors.primaryContainer;
      default:
        return SnapFoodColors.surfaceContainer;
    }
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
            decoration: BoxDecoration(
              color: _statusColor(),
              border: const Border(
                bottom: BorderSide(color: SnapFoodColors.softBorder),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '#' + order.id,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  order.time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: SnapFoodColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 15,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.customer,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  order.total,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 8),
            child: Column(
              children: [
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.quantity.toString() + '×',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: SnapFoodColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: order.status == 'Ready'
                    ? () => context.go('/restaurant/orders/' + order.id)
                    : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: order.status == 'Ready'
                      ? SnapFoodColors.primaryContainer
                      : SnapFoodColors.primary,
                  foregroundColor: SnapFoodColors.warmBlack,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                  ),
                ),
                child: Text(
                  order.status == 'New'
                      ? 'Accept & Start'
                      : order.status == 'Preparing'
                          ? 'Mark Ready'
                          : 'View Order',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KdsEmptyState extends StatelessWidget {
  const _KdsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 36,
            color: SnapFoodColors.onSurfaceVariant,
          ),
          SizedBox(height: 12),
          Text(
            'No orders in this view',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4),
          Text(
            'New kitchen orders will appear here.',
            style: TextStyle(
              fontSize: 11,
              color: SnapFoodColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _KdsHeader extends StatelessWidget {
  const _KdsHeader({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SnapFoodColors.surfaceContainerLowest,
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: wide ? 24 : 16,
          vertical: 12,
        ),
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
                  const Text(
                    'Live Orders / KDS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  if (wide)
                    const Text(
                      'Keep the kitchen moving',
                      style: TextStyle(
                        fontSize: 11,
                        color: SnapFoodColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: SnapFoodColors.softYellow,
                borderRadius: BorderRadius.circular(SnapFoodRadii.full),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Color(0xFF2E7D32)),
                  SizedBox(width: 6),
                  Text(
                    'OPEN',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            const CircleAvatar(
              radius: 18,
              backgroundColor: SnapFoodColors.primaryContainer,
              child: Icon(
                Icons.storefront,
                size: 19,
                color: SnapFoodColors.warmBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KdsSidebar extends StatelessWidget {
  const _KdsSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      decoration: const BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        border: Border(
          right: BorderSide(color: SnapFoodColors.softBorder),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: SnapFoodColors.secondary,
                child: Icon(Icons.restaurant, color: Colors.white, size: 19),
              ),
              SizedBox(width: 9),
              Text(
                'SNAP FOODD',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _KdsNav(
            label: 'Dashboard',
            icon: Icons.dashboard_rounded,
            onTap: () => context.go('/restaurant/dashboard'),
          ),
          const _KdsNav(
            label: 'Live Orders / KDS',
            icon: Icons.receipt_long_rounded,
            selected: true,
          ),
          const _KdsNav(
            label: 'Menu & Stock',
            icon: Icons.restaurant_menu_rounded,
          ),
          const _KdsNav(
            label: 'Analytics',
            icon: Icons.analytics_outlined,
          ),
          const _KdsNav(
            label: 'Settings',
            icon: Icons.settings_outlined,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SnapFoodColors.softYellow,
              borderRadius: BorderRadius.circular(SnapFoodRadii.md),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.support_agent,
                  size: 20,
                  color: SnapFoodColors.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Partner support\nAvailable 24×7',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
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

class _KdsNav extends StatelessWidget {
  const _KdsNav({
    required this.label,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SnapFoodRadii.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: selected ? SnapFoodColors.softYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(SnapFoodRadii.md),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: selected
                  ? SnapFoodColors.primary
                  : SnapFoodColors.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KdsOrder {
  const _KdsOrder({
    required this.id,
    required this.time,
    required this.customer,
    required this.status,
    required this.items,
    required this.total,
  });

  final String id;
  final String time;
  final String customer;
  final String status;
  final List<_KdsItem> items;
  final String total;
}

class _KdsItem {
  const _KdsItem({required this.name, required this.quantity});

  final String name;
  final int quantity;
}
