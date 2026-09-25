import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/theme/app_theme.dart';
import '../features/customer/presentation/cart_review_screen.dart';
import '../features/customer/presentation/checkout_screen.dart';
import '../features/customer/presentation/food_item_details_screen.dart';
import '../features/customer/presentation/home_feed_screen.dart';
import '../features/customer/presentation/live_order_tracking_screen.dart';
import '../features/customer/presentation/customer_profile_screen.dart';
import '../features/customer/presentation/restaurant_menu_screen.dart';
import '../features/customer/presentation/splash_welcome_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: Uri.base.path.isEmpty ? '/' : Uri.base.path,
  routes: [
    GoRoute(path: '/', name: 'splash-welcome', builder: (context, state) => const SplashWelcomeScreen()),
    GoRoute(path: '/home', name: 'customer-home', builder: (context, state) => const HomeFeedScreen()),
    GoRoute(path: '/restaurant', name: 'restaurant-menu', builder: (context, state) => const RestaurantMenuScreen()),
    GoRoute(path: '/cart', name: 'cart-review', builder: (context, state) => const CartReviewScreen()),
    GoRoute(path: '/checkout', name: 'checkout', builder: (context, state) => const CheckoutScreen()),
    GoRoute(path: '/order-tracking', name: 'order-tracking', builder: (context, state) => const LiveOrderTrackingScreen()),
    GoRoute(path: '/profile', name: 'customer-profile', builder: (context, state) => const CustomerProfileScreen()),
    GoRoute(
      path: '/food/:itemId',
      name: 'food-item-details',
      builder: (context, state) => FoodItemDetailsScreen(itemId: state.pathParameters['itemId'] ?? 'biryani'),
    ),
  ],
));

class SnapFoodApp extends ConsumerWidget {
  const SnapFoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Snap Food',
    debugShowCheckedModeBanner: false,
    theme: SnapFoodTheme.light,
    routerConfig: ref.watch(appRouterProvider),
  );
}
