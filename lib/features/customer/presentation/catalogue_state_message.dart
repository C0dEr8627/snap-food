import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../data/catalogue_models.dart';

class CatalogueStateMessage extends StatelessWidget {
  const CatalogueStateMessage({required this.value, required this.onRetry, this.showWhenLoaded = false, super.key});
  final AsyncValue<CatalogueSnapshot> value;
  final VoidCallback onRetry;
  final bool showWhenLoaded;

  @override
  Widget build(BuildContext context) {
    if (value.isLoading) {
      return const _CatalogueMessage(icon: Icons.cloud_download_outlined, title: 'Loading the latest catalogue…', subtitle: 'Fetching categories and products.');
    }
    if (value.hasError) {
      final message = value.error is ApiException ? (value.error as ApiException).message : 'We could not load the catalogue. Please try again.';
      return _CatalogueMessage(icon: Icons.cloud_off_outlined, title: 'Catalogue unavailable', subtitle: message, action: onRetry, actionLabel: 'Retry');
    }
    final snapshot = value.value;
    if (snapshot != null && snapshot.categories.isEmpty && snapshot.products.isEmpty) {
      return const _CatalogueMessage(icon: Icons.inventory_2_outlined, title: 'No catalogue items yet', subtitle: 'Products and categories will appear here when available.');
    }
    if (showWhenLoaded && snapshot != null) {
      return _CatalogueMessage(icon: Icons.check_circle_outline, title: 'Catalogue connected', subtitle: '${snapshot.categories.length} categories • ${snapshot.products.length} products');
    }
    return const SizedBox.shrink();
  }
}

class _CatalogueMessage extends StatelessWidget {
  const _CatalogueMessage({required this.icon, required this.title, required this.subtitle, this.action, this.actionLabel});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(SnapFoodRadii.lg), border: Border.all(color: SnapFoodColors.softBorder)),
    child: Row(children: [
      Icon(icon, color: SnapFoodColors.secondary),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(fontSize: 11, height: 1.35, color: SnapFoodColors.onSurfaceVariant)),
      ])),
      if (action != null) ...[const SizedBox(width: 8), TextButton(onPressed: action, child: Text(actionLabel!))],
    ]),
  );
}
