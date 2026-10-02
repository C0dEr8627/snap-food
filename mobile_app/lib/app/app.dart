import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/theme/app_theme.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/customer/presentation/cart_review_screen.dart';
import '../features/customer/presentation/checkout_screen.dart';
import '../features/customer/presentation/food_item_details_screen.dart';
import '../features/customer/presentation/home_feed_screen.dart';
import '../features/customer/presentation/search_screen.dart';
import '../features/customer/presentation/orders_screen.dart';
import '../features/customer/presentation/order_detail_screen.dart';
import '../features/customer/presentation/invoice_screen.dart';
import '../features/customer/presentation/favorites_screen.dart';
import '../features/customer/presentation/live_order_tracking_screen.dart';
import '../features/customer/presentation/customer_profile_screen.dart';
import '../features/customer/presentation/address_book_screen.dart';
import '../features/customer/presentation/restaurant_menu_screen.dart';
import '../features/customer/presentation/splash_welcome_screen.dart';
import '../features/customer/presentation/welcome_screen.dart';
import '../features/restaurant/presentation/restaurant_dashboard_screen.dart';
import '../features/restaurant/presentation/restaurant_kds_screen.dart';
import '../features/restaurant/presentation/restaurant_order_detail_screen.dart';
import '../features/restaurant/presentation/restaurant_menu_stock_screen.dart';
import '../features/delivery/presentation/delivery_login_onboarding_screen.dart';
import '../features/delivery/presentation/delivery_requests_screen.dart';
import '../features/delivery/presentation/delivery_duty_map_screen.dart';
import '../features/delivery/presentation/delivery_navigate_restaurant_screen.dart';
import '../features/delivery/presentation/delivery_pickup_verification_screen.dart';
import '../features/delivery/presentation/delivery_navigate_customer_screen.dart';
import '../features/delivery/presentation/delivery_verification_screen.dart';
import '../features/delivery/presentation/delivery_earnings_history_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final location = state.matchedLocation;
      const publicRoutes = {'/', '/welcome', '/home', '/login', '/register', '/delivery/login'};

      if (authState.isLoading) {
        // Keep public browsing reachable while session restoration is in flight.
        // Protected routes remain gated until the session state is known.
        return publicRoutes.contains(location) ? null : '/';
      }

      if (authState.hasError) {
        return publicRoutes.contains(location) ? null : '/welcome';
      }

      final isAuthenticated = authState.value?.isAuthenticated ?? false;
      if (!isAuthenticated && !publicRoutes.contains(location)) {
        return '/welcome';
      }

      if (isAuthenticated && (location == '/' || location == '/welcome' || location == '/login' || location == '/register')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'customer-login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'customer-register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'customer-home',
        builder: (context, state) => const HomeFeedScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'customer-search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'customer-orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/:orderId',
        name: 'customer-order-detail',
        builder: (context, state) =>
            OrderDetailScreen(orderId: state.pathParameters['orderId'] ?? ''),
      ),
      GoRoute(
        path: '/orders/:orderId/invoice',
        name: 'customer-invoice',
        builder: (context, state) =>
            InvoiceScreen(orderId: state.pathParameters['orderId'] ?? ''),
      ),
      GoRoute(
        path: '/favorites',
        name: 'customer-favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/restaurant',
        name: 'restaurant-menu',
        builder: (context, state) => const RestaurantMenuScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart-review',
        builder: (context, state) => const CartReviewScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders/:orderId/tracking',
        name: 'customer-order-tracking',
        builder: (context, state) => LiveOrderTrackingScreen(
          orderId: state.pathParameters['orderId'] ?? '',
        ),
      ),
      // Backward-compatible entry point for callers that do not yet provide an order id.
      GoRoute(
        path: '/order-tracking',
        name: 'order-tracking',
        builder: (context, state) => const LiveOrderTrackingScreen(orderId: ''),
      ),
      GoRoute(
        path: '/addresses',
        name: 'customer-addresses',
        builder: (context, state) => const AddressBookScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'customer-profile',
        builder: (context, state) => const CustomerProfileScreen(),
      ),
      GoRoute(
        path: '/restaurant/dashboard',
        name: 'restaurant-dashboard',
        builder: (context, state) => const RestaurantDashboardScreen(),
      ),
      GoRoute(
        path: '/restaurant/kds',
        name: 'restaurant-kds',
        builder: (context, state) => const RestaurantKdsScreen(),
      ),
      GoRoute(
        path: '/restaurant/orders/:orderId',
        name: 'restaurant-order-detail',
        builder: (context, state) => RestaurantOrderDetailScreen(
          orderId: state.pathParameters['orderId'] ?? 'SF10248',
        ),
      ),
      GoRoute(
        path: '/restaurant/menu-stock',
        name: 'restaurant-menu-stock',
        builder: (context, state) => const RestaurantMenuStockScreen(),
      ),
      GoRoute(
        path: '/delivery/login',
        name: 'delivery-login',
        builder: (context, state) => const DeliveryLoginOnboardingScreen(),
      ),
      GoRoute(
        path: '/delivery/requests',
        name: 'delivery-requests',
        builder: (context, state) => const DeliveryRequestsScreen(),
      ),
      GoRoute(
        path: '/delivery/duty-map',
        name: 'delivery-duty-map',
        builder: (context, state) => const DeliveryDutyMapScreen(),
      ),
      GoRoute(
        path: '/delivery/navigate-restaurant',
        name: 'delivery-navigate-restaurant',
        builder: (context, state) => const DeliveryNavigateRestaurantScreen(),
      ),
      GoRoute(
        path: '/delivery/pickup-verification',
        name: 'delivery-pickup-verification',
        builder: (context, state) => const DeliveryPickupVerificationScreen(),
      ),
      GoRoute(
        path: '/delivery/navigate-customer',
        name: 'delivery-navigate-customer',
        builder: (context, state) => const DeliveryNavigateCustomerScreen(),
      ),
      GoRoute(
        path: '/delivery/verification',
        name: 'delivery-verification',
        builder: (context, state) => const DeliveryVerificationScreen(),
      ),
      GoRoute(
        path: '/delivery/earnings',
        name: 'delivery-earnings',
        builder: (context, state) => const DeliveryEarningsHistoryScreen(),
      ),
      GoRoute(
        path: '/food/:itemId',
        name: 'food-item-details',
        builder: (context, state) => FoodItemDetailsScreen(
          itemId: state.pathParameters['itemId'] ?? 'biryani',
        ),
      ),
    ],
  );
});

class SnapFoodApp extends ConsumerWidget {
  const SnapFoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Snap Foodd',
    debugShowCheckedModeBanner: false,
    theme: SnapFoodTheme.light,
    routerConfig: ref.watch(appRouterProvider),
  );
}
