import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/snap_food_button.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../../../design_system/tokens/app_radii.dart';
import 'favorite_controller.dart';
import 'home_feed_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoriteControllerProvider);
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 76),
                child: state.when(
                  loading: () => const SnapLoadingState(message: 'Loading your favorites…'),
                  error: (error, _) => SnapErrorState(
                    title: 'Favorites are unavailable',
                    message: 'We could not load your saved dishes right now.',
                    onRetry: () => ref.read(favoriteControllerProvider.notifier).refresh(),
                  ),
                  data: (favorites) {
                    if (favorites.products.isEmpty) {
                      return Column(
                        children: [
                          const SnapEmptyState(
                            icon: Icons.favorite_border_rounded,
                            title: 'No favorites yet',
                            message: 'Save dishes you love and they will be ready here when you want them again.',
                          ),
                          SnapSecondaryButton(
                            label: 'Browse dishes',
                            icon: Icons.search_rounded,
                            onPressed: () => context.go('/home'),
                          ),
                        ],
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => ref.read(favoriteControllerProvider.notifier).refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                        itemCount: favorites.products.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Row(
                              children: [
                                const Expanded(child: Text('Your Favorites', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
                                Text('${favorites.products.length} saved', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SnapFoodColors.onSurfaceVariant)),
                              ],
                            );
                          }
                          final product = favorites.products[index - 1];
                          return Material(
                            color: SnapFoodColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
                              onTap: () => context.push('/food/${product.id}'),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    _FavoriteImage(imageUrl: product.imageUrl),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                                          const SizedBox(height: 5),
                                          Text(product.category?.name ?? 'Dish', style: const TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
                                          const SizedBox(height: 8),
                                          SnapPrice(value: product.price, fontSize: 17),
                                        ],
                                      ),
                                    ),
                                    SnapIconButton(
                                      icon: Icons.favorite_rounded,
                                      selected: true,
                                      tooltip: 'Remove from favorites',
                                      semanticLabel: 'Remove ' + product.name + ' from favorites',
                                      onPressed: () => ref.read(favoriteControllerProvider.notifier).toggle(product),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const Positioned(top: 0, left: 0, right: 0, child: HomeHeader()),
            const Positioned(left: 0, right: 0, bottom: 0, child: BottomNav(selected: 3, onSelected: _noop)),
          ],
        ),
      ),
    );
  }

  static void _noop(int _) {}
}

class _FavoriteImage extends StatelessWidget {
  const _FavoriteImage({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(SnapFoodRadii.md),
      child: url.startsWith('http')
          ? Image.network(url, width: 112, height: 112, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback())
          : _fallback(),
    );
  }

  Widget _fallback() => Container(
    width: 64,
    height: 64,
    color: SnapFoodColors.primaryContainer,
    alignment: Alignment.center,
    child: const Icon(Icons.restaurant_rounded, color: SnapFoodColors.secondary, size: 28),
  );
}
