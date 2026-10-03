import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/snap_food_inputs.dart';
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
  int? selectedCategoryId;

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
                    child: SnapSearchField(
                      controller: controller,
                      autofocus: true,
                      onChanged: (value) => setState(() => query = value),
                      onClear: () {
                        controller.clear();
                        setState(() => query = '');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SnapIconButton(
                    icon: Icons.tune_rounded,
                    tooltip: 'Filters',
                    semanticLabel: 'Open filters',
                    onPressed: _noop,
                  ),
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
                      'Browse by category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    catalogue.when(
                      loading: () => const SizedBox(
                        height: 40,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 120,
                            child: LinearProgressIndicator(),
                          ),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (snapshot) {
                        final availableCategories = snapshot.categories;
                        if (availableCategories.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SnapFilterChip(
                                label: 'All',
                                selected: selectedCategoryId == null,
                                onSelected: (_) => setState(() {
                                  selectedCategoryId = null;
                                }),
                              ),
                              for (final category in availableCategories) ...[
                                const SizedBox(width: 8),
                                SnapFilterChip(
                                  label: category.name,
                                  selected: selectedCategoryId == category.id,
                                  onSelected: (_) => setState(() {
                                    selectedCategoryId = category.id;
                                  }),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
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
                                  (selectedCategoryId == null ||
                                      product.categoryId == selectedCategoryId) &&
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
                                    query.isEmpty && selectedCategoryId == null
                                        ? 'Browse the menu'
                                        : query.isEmpty
                                            ? 'Category results'
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
          onTap: () => context.push('/food/' + product.id.toString()),
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
                  child: _CatalogueProductImage(
                    imageUrl: product.imageUrl,
                    width: 78,
                    height: 78,
                    radius: SnapFoodRadii.md,
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


class _CatalogueProductImage extends StatelessWidget {
  const _CatalogueProductImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.radius,
  });

  final String? imageUrl;
  final double width;
  final double height;
  final double radius;

  bool get _hasRemoteImage {
    final value = imageUrl?.trim() ?? '';
    return value.startsWith('https://') || value.startsWith('http://');
  }

  @override
  Widget build(BuildContext context) {
    final fallback = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: width,
        height: height,
        color: SnapFoodColors.primaryContainer,
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset(
          'assets/images/customer/logo.svg',
          fit: BoxFit.contain,
        ),
      ),
    );

    if (!_hasRemoteImage) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        imageUrl!.trim(),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}
