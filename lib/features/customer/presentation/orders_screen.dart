import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import 'home_feed_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const orders = [
    ('SF10248', 'The Bombay Tiffin', 'Chicken Dum Biryani + 2 items', '₹520', 'Delivered', 'Yesterday', Icons.check_circle),
    ('SF10193', 'Mumbai Spice Kitchen', 'Butter Chicken + Garlic Naan', '₹640', 'On the way', 'Today • 12:42 PM', Icons.delivery_dining),
    ('SF10087', 'Coastal Curry & Dosa House', 'Ghee Roast Masala Dosa', '₹190', 'Delivered', '18 Sep', Icons.check_circle),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: SnapFoodColors.surface,
    appBar: AppBar(title: const Text('Your orders'), backgroundColor: SnapFoodColors.surface, surfaceTintColor: Colors.transparent),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: SnapFoodColors.primaryContainer, borderRadius: BorderRadius.circular(SnapFoodRadii.lg)),
          child: const Row(children: [
            Icon(Icons.delivery_dining, size: 32, color: SnapFoodColors.warmBlack),
            SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('One order is on the way', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              SizedBox(height: 3),
              Text('Arriving in about 18 mins', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ])),
            Icon(Icons.chevron_right),
          ]),
        ),
        const SizedBox(height: 24),
        const Text('Order history', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...orders.map((order) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OrderCard(order: order),
        )),
      ],
    ),
    bottomNavigationBar: const BottomNav(selected: 2, onSelected: _noop),
  );

  static void _noop(int _) {}
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final (String, String, String, String, String, String, IconData) order;

  @override
  Widget build(BuildContext context) {
    final active = order.$5 == 'On the way';
    return Material(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        onTap: active ? () => context.push('/order-tracking') : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(children: [
              Container(width: 46, height: 46, decoration: BoxDecoration(color: active ? SnapFoodColors.primaryContainer : SnapFoodColors.softRed, borderRadius: BorderRadius.circular(SnapFoodRadii.md)), child: Icon(order.$7, color: active ? SnapFoodColors.warmBlack : SnapFoodColors.secondary)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(order.$3, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
              ])),
              Text(order.$4, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Text(order.$6, style: const TextStyle(fontSize: 10, color: SnapFoodColors.outline)),
              const Spacer(),
              Text(order.$5, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: active ? SnapFoodColors.secondary : SnapFoodColors.tertiary)),
              const SizedBox(width: 6),
              if (active) const Icon(Icons.chevron_right, size: 17),
            ]),
          ]),
        ),
      ),
    );
  }
}
