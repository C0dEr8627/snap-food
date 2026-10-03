import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../design_system/components/snap_food_feedback.dart';
import '../data/catalogue_models.dart';

class CatalogueStateMessage extends StatelessWidget {
  const CatalogueStateMessage({
    required this.value,
    required this.onRetry,
    this.showWhenLoaded = false,
    super.key,
  });

  final AsyncValue<CatalogueSnapshot> value;
  final VoidCallback onRetry;
  final bool showWhenLoaded;

  @override
  Widget build(BuildContext context) {
    if (value.isLoading) {
      return const SnapLoadingState(
        message: 'Fetching categories and products.',
      );
    }

    if (value.hasError) {
      final message = value.error is ApiException
          ? (value.error as ApiException).message
          : 'We could not load the catalogue. Please try again.';
      return SnapErrorState(
        title: 'Catalogue unavailable',
        message: message,
        onRetry: onRetry,
        compact: true,
      );
    }

    final snapshot = value.value;
    if (snapshot != null &&
        snapshot.categories.isEmpty &&
        snapshot.products.items.isEmpty) {
      return const SnapEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No catalogue items yet',
        message: 'Products and categories will appear here when available.',
        compact: true,
      );
    }

    if (showWhenLoaded && snapshot != null) {
      return SnapEmptyState(
        icon: Icons.check_circle_outline,
        title: 'Catalogue connected',
        message:
            '${snapshot.categories.length} categories • '
            '${snapshot.products.items.length} products',
        compact: true,
      );
    }

    return const SizedBox.shrink();
  }
}