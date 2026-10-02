import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/theme/app_theme.dart';
import '../features/auth/presentation/auth_controller.dart';
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
    initialLocation: '/delivery/login',
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoginRoute = location == '/delivery/login';

      if (authState.isLoading) {
        return isLoginRoute ? null : '/delivery/login';
      }

      if (authState.hasError) {
        return isLoginRoute ? null : '/delivery/login';
      }

      final session = authState.value;
      final isAuthenticated = session?.isAuthenticated ?? false;
      final isDeliveryPartner = session?.isDeliveryPartner ?? false;

      if (!isAuthenticated || !isDeliveryPartner) {
        return isLoginRoute ? null : '/delivery/login';
      }

      if (isLoginRoute || location == '/') {
        return '/delivery/requests';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'delivery-app',
        redirect: (context, state) => '/delivery/login',
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
    ],
  );
});

class SnapFoodApp extends ConsumerWidget {
  const SnapFoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Snap Foodd Delivery Partner',
    debugShowCheckedModeBanner: false,
    theme: SnapFoodTheme.light,
    routerConfig: ref.watch(appRouterProvider),
  );
}
