import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/snap_food_button.dart';
import '../../../design_system/components/snap_food_commerce.dart';
import '../../../design_system/components/snap_food_feedback.dart';
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
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SnapBottomSheet(
        title: 'Filter dishes',
        subtitle: 'Tune the catalogue to what you want right now.',
        child: _HomeFilterSheet(
          categories: catalogue.categories,
        selectedCategoryId: selectedCategoryId,
        onlyAvailable: onlyAvailable,
          sortLowToHigh: sortLowToHigh,
        ),
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
                          const SizedBox(height: 16),
                          SearchFilters(
                            searchQuery: searchQuery,
                            onSearchChanged: (value) => setState(() => searchQuery = value),
                            onOpenFilters: () => _openFilters(context),
                            hasActiveFilters: selectedCategoryId != null || !onlyAvailable || sortLowToHigh,
                          ),
                          const SizedBox(height: 16),
                          CategoryPills(
                            selectedCategoryId: selectedCategoryId,
                            onSelected: (value) => setState(() => selectedCategoryId = value),
                          ),
                          const SizedBox(height: 20),
                          const HomeDiscoveryHero(),
                          const SizedBox(height: 28),
                          DatabaseCatalogueSection(
                            selectedCategoryId: selectedCategoryId,
                            searchQuery: searchQuery,
                            onlyAvailable: onlyAvailable,
                            sortLowToHigh: sortLowToHigh,
                          ),
                          const SizedBox(height: 28),
                          const HomeDiscoveryNote(),
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
      builder: (dialogContext) => SnapAlertDialog(
        title: 'Exit Snap Foodd?',
        message: 'Are you sure you want to exit the application?',
        cancelLabel: 'Cancel',
        confirmLabel: 'Exit',
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
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

class HomeDiscoveryHero extends ConsumerWidget {
  const HomeDiscoveryHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogue = ref.watch(catalogueControllerProvider);

    return catalogue.maybeWhen(
      data: (snapshot) {
        final available = snapshot.products.items
            .where((product) => product.isActive && product.isAvailable)
            .toList();
        if (available.isEmpty) return const SizedBox.shrink();

        final featured = available.firstWhere(
          (product) => product.imageUrl?.trim().isNotEmpty == true,
          orElse: () => available.first,
        );

        return _DiscoveryHeroContent(product: featured);
      },
      loading: () => const _DiscoveryHeroSkeleton(),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _DiscoveryHeroContent extends StatelessWidget {
  const _DiscoveryHeroContent({required this.product});

  final CatalogueProduct product;

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrl?.trim().isNotEmpty == true;

    return Semantics(
      container: true,
      label: 'Featured dish',
      child: Material(
        color: SnapFoodColors.warmBlack,
        borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/food/' + product.id.toString()),
          child: SizedBox(
            height: 208,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  Image.network(
                    product.imageUrl!.trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        SnapFoodColors.warmBlack.withAlpha(20),
                        SnapFoodColors.warmBlack.withAlpha(215),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: SnapFoodColors.accentYellow,
                                borderRadius: BorderRadius.circular(SnapFoodRadii.full),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                child: Text(
                                  'Made for right now',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: SnapFoodColors.warmBlack,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            SnapPrice(
                              value: product.price,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: SnapFoodColors.primaryContainer,
                          borderRadius: BorderRadius.circular(SnapFoodRadii.full),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View dish',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: SnapFoodColors.warmBlack,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: SnapFoodColors.warmBlack,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _DiscoveryHeroSkeleton extends StatelessWidget {
  const _DiscoveryHeroSkeleton();

  @override
  Widget build(BuildContext context) => const SnapSkeleton(
        height: 208,
        borderRadius: SnapFoodRadii.xl,
      );
}

/// The current consumer catalogue contract exposes dishes/categories, not a
/// restaurant discovery collection. Keep this surface honest until a
/// restaurant feed is available instead of fabricating restaurant data.
class HomeDiscoveryNote extends StatelessWidget {
  const HomeDiscoveryNote({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SnapFoodSpacing.md),
          child: Row(
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: SnapFoodColors.softYellow,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(
                    Icons.storefront_outlined,
                    size: 18,
                    color: SnapFoodColors.warmBlack,
                  ),
                ),
              ),
              const SizedBox(width: SnapFoodSpacing.md),
              const Expanded(
                child: Text(
                  'Restaurant discovery will appear here when the consumer API exposes restaurant data.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: SnapFoodColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
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
      loading: () => SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, __) => const SizedBox(
            width: 214,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SnapSkeleton(height: 150, borderRadius: SnapFoodRadii.lg),
                SizedBox(height: 10),
                SnapSkeleton(width: 150, height: 14),
                SizedBox(height: 8),
                SnapSkeleton(width: 90, height: 14),
              ],
            ),
          ),
        ),
      ),
      error: (error, _) => CatalogueStateMessage(
        value: catalogue,
        onRetry: () => ref.read(catalogueControllerProvider.notifier).retry(),
      ),
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
          return const SnapEmptyState(
            icon: Icons.restaurant_menu_outlined,
            title: 'Nothing here yet',
            message: 'Try another category or search to explore available dishes.',
            compact: true,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SnapSectionHeader(
              title: 'Popular dishes',
              subtitle: products.length.toString() + ' items',
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

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});

  final CatalogueProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite =
        ref.watch(favoriteControllerProvider).value?.contains(product.id) ??
        false;

    return SnapProductCard(
      name: product.name,
      price: product.price,
      category: product.category?.name,
      isAvailable: product.isAvailable,
      isFavorite: isFavorite,
      image: _CatalogueProductImage(
        imageUrl: product.imageUrl,
        width: 216,
        height: 150,
        radius: SnapFoodRadii.lg,
      ),
      onTap: () => context.push('/food/${product.id}'),
      onFavorite: () =>
          ref.read(favoriteControllerProvider.notifier).toggle(product),
      onAction: product.isAvailable
          ? () => context.push('/food/${product.id}')
          : null,
      actionLabel: 'View dish',
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
                  SnapIconButton(
                    icon: Icons.shopping_bag_outlined,
                    tooltip: 'Cart',
                    semanticLabel: 'Open cart',
                    onPressed: () => context.push('/cart'),
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
              const SizedBox(width: 4),
              const SnapIconButton(
                icon: Icons.notifications_none_rounded,
                tooltip: 'Notifications',
                semanticLabel: 'Notifications',
                onPressed: null,
              ),
              Semantics(
                button: true,
                label: 'Open profile',
                child: InkWell(
                  onTap: () => context.go('/profile'),
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
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
    final selectedAddress =
        ref.watch(addressBookControllerProvider).value?.selectedAddress;
    final label = selectedAddress?.label ?? 'Use current location';
    final detail = selectedAddress?.displayLine;

    return Semantics(
      button: true,
      label: detail == null || detail.isEmpty
          ? 'Delivery address: $label. Open delivery address options'
          : 'Delivery address: $label, $detail. Change delivery address',
      child: InkWell(
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
              const Icon(
                Icons.location_on,
                size: 18,
                color: SnapFoodColors.secondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  detail == null || detail.isEmpty ? label : '$label · $detail',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.expand_more,
                size: 18,
                color: SnapFoodColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
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
              hintText: 'What are you craving?',
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
                    child: Semantics(
                      button: true,
                      selected: i == selected,
                      label: items[i].$2,
                      child: InkWell(
                      onTap: () {
                        if (i != selected) {
                          HapticFeedback.selectionClick();
                        }
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                        child: AnimatedContainer(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 110),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            color: i == selected
                                ? SnapFoodColors.softYellow
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(SnapFoodRadii.full),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                items[i].$1,
                                size: 21,
                                color: i == selected
                                    ? SnapFoodColors.warmBlack
                                    : SnapFoodColors.onSurfaceVariant,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                items[i].$2,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: i == selected
                                      ? SnapFoodColors.warmBlack
                                      : SnapFoodColors.onSurfaceVariant,
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
