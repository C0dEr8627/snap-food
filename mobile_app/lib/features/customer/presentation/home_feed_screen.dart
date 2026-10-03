import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/snap_food_inputs.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/catalogue_models.dart';
import 'catalogue_controller.dart';
import 'catalogue_state_message.dart';
import 'cart_controller.dart';
import 'address_book_controller.dart';
import 'favorite_controller.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  int nav = 0;
  int? selectedCategoryId;
  String searchQuery = '';
  bool onlyAvailable = true;
  bool sortLowToHigh = false;

  Future<void> _openFilters(BuildContext context) async {
    final catalogueState = ref.read(catalogueControllerProvider);
    final catalogue = catalogueState.asData?.value;
    if (catalogue == null) return;

    final result = await showModalBottomSheet<_HomeFilterResult>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _HomeFilterSheet(
        categories: catalogue.categories,
        selectedCategoryId: selectedCategoryId,
        onlyAvailable: onlyAvailable,
        sortLowToHigh: sortLowToHigh,
      ),
    );

    if (!mounted || result == null) return;
    setState(() {
      selectedCategoryId = result.categoryId;
      onlyAvailable = result.onlyAvailable;
      sortLowToHigh = result.sortLowToHigh;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmExit(context);
      },
      child: Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 76, bottom: 88 + MediaQuery.paddingOf(context).bottom),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: SnapFoodSpacing.desktopMaxContentWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Greeting(),
                          const SizedBox(height: 20),
                          Consumer(
                            builder: (context, ref, _) {
                              final catalogue = ref.watch(catalogueControllerProvider);
                              return CatalogueStateMessage(
                                value: catalogue,
                                onRetry: () => ref.read(catalogueControllerProvider.notifier).retry(),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          SearchFilters(
                            searchQuery: searchQuery,
                            onSearchChanged: (value) => setState(() => searchQuery = value),
                            onOpenFilters: () => _openFilters(context),
                            hasActiveFilters: selectedCategoryId != null || !onlyAvailable || sortLowToHigh,
                          ),
                          const SizedBox(height: 18),
                          CategoryPills(
                            selectedCategoryId: selectedCategoryId,
                            onSelected: (value) => setState(() => selectedCategoryId = value),
                          ),
                          const SizedBox(height: 22),
                          DatabaseCatalogueSection(
                            selectedCategoryId: selectedCategoryId,
                            searchQuery: searchQuery,
                            onlyAvailable: onlyAvailable,
                            sortLowToHigh: sortLowToHigh,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(top: 0, left: 0, right: 0, child: HomeHeader()),
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: BottomNav(selected: nav, onSelected: (value) => setState(() => nav = value)),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit Snap Foodd?'),
        content: const Text('Are you sure you want to exit the application?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: SnapFoodColors.secondary, foregroundColor: Colors.white),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (shouldExit == true) await SystemNavigator.pop();
  }
}

class CategoryPills extends ConsumerWidget {
  const CategoryPills({required this.selectedCategoryId, required this.onSelected});

  final int? selectedCategoryId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogue = ref.watch(catalogueControllerProvider);
    return catalogue.maybeWhen(
      data: (snapshot) {
        final categories = snapshot.categories;
        if (categories.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 2),
            itemCount: categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final isAll = index == 0;
              final category = isAll ? null : categories[index - 1];
              final selected = isAll ? selectedCategoryId == null : selectedCategoryId == category!.id;
              return SnapCategoryChip(
                selected: selected,
                onSelected: () => onSelected(isAll ? null : category!.id),
                label: isAll ? 'All' : category!.name,
                icon: isAll
                    ? Icons.grid_view_rounded
                    : Icons.restaurant_rounded,
              );
            },
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class DatabaseCatalogueSection extends ConsumerWidget {
  const DatabaseCatalogueSection({
    super.key,
    this.selectedCategoryId,
    this.searchQuery = '',
    this.onlyAvailable = true,
    this.sortLowToHigh = false,
  });

  final int? selectedCategoryId;
  final String searchQuery;
  final bool onlyAvailable;
  final bool sortLowToHigh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogue = ref.watch(catalogueControllerProvider);
    return catalogue.when(
      loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
      error: (error, _) => const SizedBox.shrink(),
      data: (snapshot) {
        final normalizedQuery = searchQuery.trim().toLowerCase();
        final products = snapshot.products.items
            .where((product) => product.isActive)
            .where((product) => !onlyAvailable || product.isAvailable)
            .where((product) => selectedCategoryId == null || product.categoryId == selectedCategoryId)
            .where((product) =>
                normalizedQuery.isEmpty ||
                product.name.toLowerCase().contains(normalizedQuery) ||
                (product.category?.name.toLowerCase().contains(normalizedQuery) ?? false))
            .toList()
          ..sort((a, b) {
            if (!sortLowToHigh) return 0;
            final aPrice = double.tryParse(a.price.replaceAll(',', '')) ?? double.infinity;
            final bPrice = double.tryParse(b.price.replaceAll(',', '')) ?? double.infinity;
            return aPrice.compareTo(bPrice);
          });

        if (products.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: SnapFoodColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
              border: Border.all(color: SnapFoodColors.outline.withAlpha(25)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nothing here yet', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                SizedBox(height: 5),
                Text('Try another category to explore available dishes.', style: TextStyle(fontSize: 12, color: SnapFoodColors.onSurfaceVariant)),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Popular dishes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
                Text('${products.length} items', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SnapFoodColors.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 278,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) => _ProductCard(product: products[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final CatalogueProduct product;

  @override
  Widget build(BuildContext context) {
    const cardRadius = 20.0;
    const imageHeight = 154.0;

    return SizedBox(
      width: 214,
      height: 278,
      child: Material(
        color: SnapFoodColors.surfaceContainerLowest,
        elevation: 0,
        borderRadius: BorderRadius.circular(cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/food/${product.id}'),
          borderRadius: BorderRadius.circular(cardRadius),
          splashColor: SnapFoodColors.primaryContainer.withAlpha(35),
          highlightColor: SnapFoodColors.primaryContainer.withAlpha(18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: SnapFoodColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: SnapFoodColors.softBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  spreadRadius: -6,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _CatalogueProductImage(
                        imageUrl: product.imageUrl,
                        width: 214,
                        height: imageHeight,
                        radius: cardRadius,
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final isFavorite = ref.watch(favoriteControllerProvider).value?.contains(product.id) ?? false;
                          return Positioned(
                            top: 10,
                            right: 10,
                            child: Material(
                              color: SnapFoodColors.surfaceContainerLowest.withAlpha(235),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => ref.read(favoriteControllerProvider.notifier).toggle(product),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                    color: SnapFoodColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: SnapFoodColors.surfaceContainerLowest.withAlpha(235),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: SnapFoodColors.softBorder.withAlpha(180),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 13,
                                  color: SnapFoodColors.secondary,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Fresh',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Material(
                          color: SnapFoodColors.primaryContainer,
                          shape: const CircleBorder(),
                          elevation: 4,
                          shadowColor: SnapFoodColors.warmBlack.withAlpha(45),
                          child: InkWell(
                            onTap: () => context.push('/food/${product.id}'),
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(9),
                              child: Icon(
                                Icons.add_rounded,
                                color: SnapFoodColors.warmBlack,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                            color: SnapFoodColors.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                '₹${product.price}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.1,
                                  fontWeight: FontWeight.w900,
                                  color: SnapFoodColors.secondary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: SnapFoodColors.softYellow,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 13,
                                    color: SnapFoodColors.primary,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '4.8',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: SnapFoodColors.warmBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeHeader extends ConsumerWidget {
  const HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    return Material(
      color: SnapFoodColors.surface.withAlpha(242),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              const Expanded(
                child: SizedBox(
                  height: 44,
                  child: _DeliveryLocation(),
                ),
              ),
              const SizedBox(width: 4),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => context.push('/cart'),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    tooltip: 'Cart',
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 3,
                      top: 3,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: const BoxDecoration(
                          color: SnapFoodColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cart.itemCount > 99 ? '99+' : cart.itemCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
              ),
              InkWell(
                onTap: () => context.go('/profile'),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: SnapFoodColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: SnapFoodColors.warmBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryLocation extends ConsumerWidget {
  const _DeliveryLocation();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAddress = ref.watch(addressBookControllerProvider).value?.selectedAddress;
    final label = selectedAddress?.label ?? 'Choose a delivery address';
    final detail = selectedAddress?.displayLine;
    return InkWell(
      onTap: () => context.push('/addresses'),
      borderRadius: BorderRadius.circular(SnapFoodRadii.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainer,
        borderRadius: BorderRadius.circular(SnapFoodRadii.full),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 18,
            color: SnapFoodColors.secondary,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              detail == null || detail.isEmpty ? label : '$label · $detail',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Icon(
            Icons.expand_more,
            size: 18,
            color: SnapFoodColors.outline,
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit Snap Foodd?'),
        content: const Text('Are you sure you want to exit the application?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: SnapFoodColors.secondary, foregroundColor: Colors.white),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (shouldExit == true) await SystemNavigator.pop();
  }
}

class Greeting extends ConsumerWidget {
  const Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.value?.user?.payload ?? const <String, dynamic>{};
    final rawName = (user['name'] ?? '').toString().trim();
    final firstName =
        rawName.isEmpty ? 'there' : rawName.split(RegExp(r'\s+')).first;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : (hour < 17 ? 'Good afternoon' : 'Good evening');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $firstName! 🍕',
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'What are you craving today?',
                style: TextStyle(
                  fontSize: 14,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchFilters extends StatefulWidget {
  const SearchFilters({
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onOpenFilters,
    required this.hasActiveFilters,
  });

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilters;
  final bool hasActiveFilters;

  @override
  State<SearchFilters> createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.searchQuery);

  @override
  void didUpdateWidget(covariant SearchFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.searchQuery,
        selection: TextSelection.collapsed(offset: widget.searchQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: SnapSearchField(
              controller: _controller,
              onChanged: widget.onSearchChanged,
              showMic: true,
              onClear: () {
                _controller.clear();
                widget.onSearchChanged('');
              },
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              SnapIconButton(
                icon: Icons.tune_rounded,
                tooltip: 'Filters',
                semanticLabel: 'Open filters',
                selected: widget.hasActiveFilters,
                onPressed: widget.onOpenFilters,
              ),
              if (widget.hasActiveFilters)
                const Positioned(
                  right: -1,
                  top: -1,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: SnapFoodColors.foodRed,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 10, height: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
}

class _HomeFilterResult {
  const _HomeFilterResult({
    required this.categoryId,
    required this.onlyAvailable,
    required this.sortLowToHigh,
  });

  final int? categoryId;
  final bool onlyAvailable;
  final bool sortLowToHigh;
}

class _HomeFilterSheet extends StatefulWidget {
  const _HomeFilterSheet({
    required this.categories,
    required this.selectedCategoryId,
    required this.onlyAvailable,
    required this.sortLowToHigh,
  });

  final List<CatalogueCategory> categories;
  final int? selectedCategoryId;
  final bool onlyAvailable;
  final bool sortLowToHigh;

  @override
  State<_HomeFilterSheet> createState() => _HomeFilterSheetState();
}

class _HomeFilterSheetState extends State<_HomeFilterSheet> {
  late int? categoryId = widget.selectedCategoryId;
  late bool onlyAvailable = widget.onlyAvailable;
  late bool sortLowToHigh = widget.sortLowToHigh;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter dishes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SnapFilterChip(
                    label: 'All',
                    selected: categoryId == null,
                    onSelected: (_) => setState(() => categoryId = null),
                  ),
                  for (final category in widget.categories)
                    SnapFilterChip(
                      label: category.name,
                      selected: categoryId == category.id,
                      onSelected: (_) =>
                          setState(() => categoryId = category.id),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Available now', style: TextStyle(fontWeight: FontWeight.w700)),
                value: onlyAvailable,
                onChanged: (value) => setState(() => onlyAvailable = value),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Price: low to high', style: TextStyle(fontWeight: FontWeight.w700)),
                value: sortLowToHigh,
                onChanged: (value) => setState(() => sortLowToHigh = value),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    _HomeFilterResult(
                      categoryId: categoryId,
                      onlyAvailable: onlyAvailable,
                      sortLowToHigh: sortLowToHigh,
                    ),
                  ),
                  child: const Text('Apply filters'),
                ),
              ),
            ],
          ),
        ),
      );
}

class BottomNav extends StatelessWidget {
  const BottomNav({
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  static const items = [
    (Icons.storefront, 'Home'),
    (Icons.search, 'Search'),
    (Icons.receipt_long, 'Orders'),
    (Icons.favorite, 'Favorites'),
  ];

  @override
  Widget build(BuildContext context) => Material(
        color: SnapFoodColors.surface.withAlpha(247),
        elevation: 12,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        switch (i) {
                          case 0:
                            context.go('/home');
                            break;
                          case 1:
                            context.go('/search');
                            break;
                          case 2:
                            context.go('/orders');
                            break;
                          case 3:
                            context.go('/favorites');
                            break;
                        }
                        onSelected(i);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[i].$1,
                            size: 22,
                            color: i == selected
                                ? SnapFoodColors.secondary
                                : SnapFoodColors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[i].$2,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: i == selected
                                  ? SnapFoodColors.secondary
                                  : SnapFoodColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
