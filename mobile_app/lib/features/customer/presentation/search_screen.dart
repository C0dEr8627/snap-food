import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import 'catalogue_controller.dart';
import 'catalogue_state_message.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../data/catalogue_models.dart';
import 'home_feed_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final controller = TextEditingController();
  String query = '';

  static const categories = [
    (Icons.rice_bowl, 'Biryani'),
    (Icons.local_pizza, 'Pizza'),
    (Icons.lunch_dining, 'Burgers'),
    (Icons.tapas, 'Street Food'),
    (Icons.coffee, 'Cafés'),
    (Icons.icecream, 'Desserts'),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogue = ref.watch(catalogueControllerProvider);
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      onChanged: (value) => setState(() => query = value),
                      decoration: InputDecoration(
                        hintText: 'Search dishes, restaurants...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  controller.clear();
                                  setState(() => query = '');
                                },
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CatalogueStateMessage(
                      value: catalogue,
                      onRetry: () => ref
                          .read(catalogueControllerProvider.notifier)
                          .retry(),
                    ),
                    const Text(
                      'Search by craving',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 102,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => InkWell(
                          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
                          onTap: () {
                            controller.text = categories[i].$2;
                            setState(() => query = categories[i].$2);
                          },
                          child: Container(
                            width: 82,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: SnapFoodColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(
                                SnapFoodRadii.lg,
                              ),
                              border: Border.all(
                                color: SnapFoodColors.softBorder,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: const BoxDecoration(
                                    color: SnapFoodColors.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    categories[i].$1,
                                    color: SnapFoodColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  categories[i].$2,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    catalogue.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (snapshot) {
                        final normalizedQuery = query.trim().toLowerCase();
                        final results = snapshot.products.items
                            .where(
                              (product) =>
                                  product.isActive &&
                                  product.isAvailable &&
                                  (normalizedQuery.isEmpty ||
                                      product.name
                                          .toLowerCase()
                                          .contains(normalizedQuery) ||
                                      (product.category?.name
                                              .toLowerCase()
                                              .contains(normalizedQuery) ??
                                          false)),
                            )
                            .toList(growable: false);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    query.isEmpty
                                        ? 'Popular near you'
                                        : 'Results for “$query”',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (query.isNotEmpty)
                                  Text(
                                    '${results.length} items',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: SnapFoodColors.outline,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (results.isEmpty)
                              _EmptySearch(query: query)
                            else
                              ...results.map(
                                (product) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _SearchResultCard(product: product),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(selected: 1, onSelected: _noop),
    );
  }

  static void _noop(int _) {}
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.product});

  final CatalogueProduct product;

  @override
  Widget build(BuildContext context) => Material(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          onTap: () => context.push('/product/' + product.id.toString()),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: SnapFoodColors.primaryContainer,
                    borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: SnapFoodColors.secondary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category?.name ?? 'Menu item',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: SnapFoodColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '₹' + product.price,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: SnapFoodColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: SnapFoodColors.outline),
              ],
            ),
          ),
        ),
      );
}
class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
    ),
    child: Column(
      children: [
        const Icon(Icons.search_off, size: 42, color: SnapFoodColors.outline),
        const SizedBox(height: 12),
        Text(
          'No matches for “$query”',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Try a dish or category name.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: SnapFoodColors.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

