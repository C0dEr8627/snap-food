import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/theme/app_theme.dart';
import '../features/customer/presentation/home_feed_screen.dart';
import '../features/customer/presentation/splash_welcome_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash-welcome',
      builder: (context, state) => const SplashWelcomeScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'customer-home',
      builder: (context, state) => const HomeFeedScreen(),
    ),
  ],
));

class SnapFoodApp extends ConsumerWidget {
  const SnapFoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Snap Food',
      debugShowCheckedModeBanner: false,
      theme: SnapFoodTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
