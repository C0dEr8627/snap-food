import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/theme/app_theme.dart';
import '../features/foundation/presentation/foundation_preview_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: '/',
  routes: [GoRoute(
    path: '/',
    name: 'foundation',
    builder: (context, state) => const FoundationPreviewScreen(),
  )],
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
