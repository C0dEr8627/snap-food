import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/catalogue_models.dart';
import 'catalogue_controller.dart';
import 'catalogue_state_message.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  int filter = 0;
  int nav = 0;
  int? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          SearchFilters(selected: filter, onSelected: (value) => setState(() => filter = value)),
                          const SizedBox(height: 18),
                          CategoryPills(
                            selectedCategoryId: selectedCategoryId,
                            onSelected: (value) => setState(() => selectedCategoryId = value),
                          ),
                          const SizedBox(height: 22),
                          DatabaseCatalogueSection(selectedCategoryId: selectedCategoryId),
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
    );
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
              return ChoiceChip(
                selected: selected,
                showCheckmark: false,
                onSelected: (_) => onSelected(isAll ? null : category!.id),
                label: Text(isAll ? 'All' : category!.name),
                avatar: Icon(isAll ? Icons.grid_view_rounded : Icons.restaurant_rounded, size: 16),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: selected ? SnapFoodColors.warmBlack : SnapFoodColors.onSurfaceVariant,
                ),
                backgroundColor: SnapFoodColors.surfaceContainerLowest,
                selectedColor: SnapFoodColors.primaryContainer,
                side: BorderSide(color: selected ? SnapFoodColors.primary.withAlpha(90) : SnapFoodColors.outline.withAlpha(28)),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 5),
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
  const DatabaseCatalogueSection({super.key, this.selectedCategoryId});
  final int? selectedCategoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogue = ref.watch(catalogueControllerProvider);
    return catalogue.when(
      loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
      error: (error, _) => const SizedBox.shrink(),
      data: (snapshot) {
        final products = snapshot.products.items
            .where((product) => product.isActive && product.isAvailable)
            .where((product) => selectedCategoryId == null || product.categoryId == selectedCategoryId)
            .toList(growable: false);

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

class HomeHeader extends StatelessWidget {
  const HomeHeader();

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(width: 8),
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

class _DeliveryLocation extends StatelessWidget {
  const _DeliveryLocation();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainer,
        borderRadius: BorderRadius.circular(SnapFoodRadii.full),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.location_on,
            size: 18,
            color: SnapFoodColors.secondary,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Choose a delivery address',
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
        const FastBadge(),
      ],
    );
  }
}

class FastBadge extends StatelessWidget {
  const FastBadge();

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: SnapFoodColors.primaryContainer.withAlpha(80),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.two_wheeler,
          color: SnapFoodColors.secondary,
          size: 26,
        ),
      );
}

class SearchFilters extends StatelessWidget {
  const SearchFilters({
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  static const filters = [
    'Filters',
    'Under 25 mins',
    'Rating 4.5+',
    'Great Offers',
    'Pure Veg',
  ];

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search dishes, restaurants...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: Icon(Icons.mic_none),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                height: 48,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: SnapFoodColors.primaryContainer,
                    foregroundColor: SnapFoodColors.warmBlack,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                    ),
                  ),
                  child: const Icon(Icons.tune),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) => FilterChip(
                selected: selected == index,
                showCheckmark: false,
                onSelected: (_) => onSelected(index),
                backgroundColor: SnapFoodColors.surfaceContainerLowest,
                selectedColor: SnapFoodColors.surfaceContainerHigh,
                side: BorderSide.none,
                shape: const StadiumBorder(),
                avatar: Icon(
                  [
                    Icons.tune,
                    Icons.bolt,
                    Icons.star,
                    Icons.local_offer,
                    Icons.eco,
                  ][index],
                  size: 15,
                  color: index == 2
                      ? SnapFoodColors.primary
                      : SnapFoodColors.secondary,
                ),
                label: Text(filters[index]),
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
    (Icons.person, 'Profile'),
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
                          case 4:
                            context.go('/profile');
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
