import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import 'home_feed_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static const saved = [
    (
      'Mumbai Spice Kitchen',
      'Butter Chicken & Naan Combo',
      '4.8',
      '20–25 mins',
      Icons.restaurant,
    ),
    (
      'The Bombay Tiffin',
      'Special Butter Pav Bhaji',
      '4.9',
      '25–30 mins',
      Icons.lunch_dining,
    ),
    (
      'Coastal Curry & Dosa House',
      'Ghee Roast Masala Dosa',
      '4.7',
      '20–25 mins',
      Icons.restaurant_menu,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: SnapFoodColors.surface,
    body: SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 76),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
      children: [
        const Text(
          'Your saved places',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Keep the spots you love close by.',
          style: TextStyle(
            fontSize: 12,
            color: SnapFoodColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ...saved.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: SnapFoodColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
              child: InkWell(
                borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
                onTap: () => context.push('/restaurant'),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: SnapFoodColors.softRed,
                          borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                        ),
                        child: Icon(
                          item.$5,
                          color: SnapFoodColors.secondary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$1,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: SnapFoodColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 13,
                                  color: SnapFoodColors.primary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  item.$3,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  item.$4,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: SnapFoodColors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.favorite,
                          color: SnapFoodColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
                ],
              ),
            ),
          ),
          const Positioned(top: 0, left: 0, right: 0, child: HomeHeader()),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNav(selected: 3, onSelected: _noop),
          ),
        ],
      ),
    ),
  );

  static void _noop(int _) {}
}
