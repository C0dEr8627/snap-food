import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';

/// Strong, reusable price hierarchy for food-commerce surfaces.
class SnapPrice extends StatelessWidget {
  const SnapPrice({
    required this.value,
    this.oldValue,
    this.currencySymbol = '₹',
    this.fontSize = 18,
    this.color = SnapFoodColors.secondary,
    super.key,
  });

  final String value;
  final String? oldValue;
  final String currencySymbol;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
        label: oldValue == null
            ? 'Price $currencySymbol$value'
            : 'Price $currencySymbol$value, previous price $currencySymbol$oldValue',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$currencySymbol$value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                height: 1,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            if (oldValue != null) ...[
              const SizedBox(width: SnapFoodSpacing.sm),
              Text(
                '$currencySymbol$oldValue',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize * .68,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.lineThrough,
                  color: SnapFoodColors.outline,
                ),
              ),
            ],
          ],
        ),
      );
}

/// Compact rating treatment with an optional review count.
class SnapRatingBadge extends StatelessWidget {
  const SnapRatingBadge({
    required this.rating,
    this.reviewCount,
    this.compact = false,
    super.key,
  });

  final double rating;
  final int? reviewCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final safeRating = rating.clamp(0, 5).toStringAsFixed(1);
    final label = reviewCount == null
        ? 'Rated $safeRating out of 5'
        : 'Rated $safeRating out of 5, $reviewCount reviews';
    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 9,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: SnapFoodColors.softYellow,
          borderRadius: BorderRadius.circular(SnapFoodRadii.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              size: compact ? 13 : 15,
              color: SnapFoodColors.primary,
            ),
            const SizedBox(width: 3),
            Text(
              safeRating,
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w800,
                color: SnapFoodColors.warmBlack,
              ),
            ),
            if (reviewCount != null) ...[
              const SizedBox(width: 3),
              Text(
                '($reviewCount)',
                style: TextStyle(
                  fontSize: compact ? 9 : 10,
                  fontWeight: FontWeight.w600,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tactile quantity control with explicit minimum/maximum bounds.
class SnapQuantityStepper extends StatelessWidget {
  const SnapQuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    this.min = 1,
    this.max = 99,
    this.compact = false,
    super.key,
  });

  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final int min;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final decrementEnabled = quantity > min && onDecrement != null;
    final incrementEnabled = quantity < max && onIncrement != null;
    final height = compact ? 40.0 : 48.0;
    final buttonSize = compact ? 40.0 : 48.0;
    return Semantics(
      container: true,
      label: 'Quantity $quantity',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: SnapFoodColors.secondary,
          borderRadius: BorderRadius.circular(SnapFoodRadii.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepperButton(
              icon: Icons.remove_rounded,
              tooltip: 'Decrease quantity',
              enabled: decrementEnabled,
              size: buttonSize,
              onPressed: decrementEnabled ? onDecrement : null,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: compact ? 24 : 30),
              child: Text(
                quantity.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w900,
                  color: SnapFoodColors.onSecondary,
                ),
              ),
            ),
            _StepperButton(
              icon: Icons.add_rounded,
              tooltip: 'Increase quantity',
              enabled: incrementEnabled,
              size: buttonSize,
              onPressed: incrementEnabled ? onIncrement : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.size,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final double size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          constraints: BoxConstraints(
            minWidth: size,
            minHeight: size,
          ),
          padding: EdgeInsets.zero,
          icon: Icon(
            icon,
            size: 18,
            color: enabled
                ? SnapFoodColors.onSecondary
                : SnapFoodColors.onSecondary.withAlpha(110),
          ),
        ),
      );
}

/// Consistent add-to-cart action that keeps the price visible.
class SnapAddToCartButton extends StatelessWidget {
  const SnapAddToCartButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool loading;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onPressed != null && !loading;
    return Semantics(
      button: true,
      enabled: active,
      label: semanticLabel ?? label,
      child: SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: active ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: SnapFoodColors.foodRed,
            foregroundColor: SnapFoodColors.onPrimary,
            disabledBackgroundColor: SnapFoodColors.outlineVariant,
            disabledForegroundColor: SnapFoodColors.onSurfaceVariant,
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SnapFoodRadii.full),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: SnapFoodSpacing.lg,
            ),
          ),
          child: loading
              ? const SizedBox.square(
                  dimension: 21,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
        ),
      ),
    );
  }
}

/// Reusable section heading with optional supporting copy and action.
class SnapSectionHeader extends StatelessWidget {
  const SnapSectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: SnapFoodColors.warmBlack,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: SnapFoodSpacing.xs),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: SnapFoodColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: SnapFoodSpacing.md),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: SnapFoodColors.secondary,
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: SnapFoodSpacing.sm,
                ),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      );
}


/// Editorial food card with image-led hierarchy and feature-owned actions.
class SnapProductCard extends StatelessWidget {
  const SnapProductCard({
    required this.name,
    required this.price,
    required this.image,
    this.category,
    this.isAvailable = true,
    this.isFavorite = false,
    this.onTap,
    this.onFavorite,
    this.onAction,
    this.actionLabel = 'View',
    this.badgeLabel,
    this.width = 216,
    this.imageHeight = 150,
    super.key,
  });

  final String name;
  final String price;
  final Widget image;
  final String? category;
  final bool isAvailable;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onAction;
  final String actionLabel;
  final String? badgeLabel;
  final double width;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    final radius = SnapFoodRadii.lg;
    final actionEnabled = isAvailable && onAction != null;

    return Semantics(
      container: true,
      label: '$name, price ₹$price${category == null ? '' : ', $category'}${isAvailable ? '' : ', unavailable'}',
      child: SizedBox(
        width: width,
        child: Material(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: SnapFoodColors.softBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        image,
                        if (badgeLabel != null)
                          Positioned(
                            top: SnapFoodSpacing.sm,
                            left: SnapFoodSpacing.sm,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: SnapFoodColors.surfaceContainerLowest.withAlpha(235),
                                borderRadius: BorderRadius.circular(SnapFoodRadii.full),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SnapFoodSpacing.sm,
                                  vertical: SnapFoodSpacing.xs,
                                ),
                                child: Text(
                                  badgeLabel!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: SnapFoodColors.warmBlack,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (onFavorite != null)
                          Positioned(
                            top: SnapFoodSpacing.sm,
                            right: SnapFoodSpacing.sm,
                            child: Semantics(
                              button: true,
                              label: isFavorite
                                  ? 'Remove $name from favorites'
                                  : 'Add $name to favorites',
                              child: Material(
                                color: SnapFoodColors.surfaceContainerLowest.withAlpha(235),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: onFavorite,
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      size: 18,
                                      color: SnapFoodColors.secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (onAction != null)
                          Positioned(
                            right: SnapFoodSpacing.sm,
                            bottom: SnapFoodSpacing.sm,
                            child: Semantics(
                              button: true,
                              enabled: actionEnabled,
                              label: actionEnabled ? actionLabel : '$name unavailable',
                              child: Material(
                                color: actionEnabled
                                    ? SnapFoodColors.primaryContainer
                                    : SnapFoodColors.outlineVariant,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  onTap: actionEnabled ? onAction : null,
                                  customBorder: const CircleBorder(),
                                  child: const SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: SnapFoodColors.warmBlack,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SnapFoodSpacing.md,
                      SnapFoodSpacing.sm + SnapFoodSpacing.xs,
                      SnapFoodSpacing.md,
                      SnapFoodSpacing.sm + 2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (category != null) ...[
                          Text(
                            category!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: SnapFoodColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: SnapFoodSpacing.xs),
                        ],
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                            color: SnapFoodColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: SnapFoodSpacing.sm),
                        SnapPrice(value: price, fontSize: 17),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// Reusable delivery-address tile with a clear, non-color-only selected state.
class SnapAddressTile extends StatelessWidget {
  const SnapAddressTile({
    required this.label,
    required this.recipientName,
    required this.addressLine,
    this.selected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final String label;
  final String recipientName;
  final String addressLine;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        selected: selected,
        label: label + (selected ? ', selected' : '') + '. ' + recipientName + '. ' + addressLine,
        child: Material(
          color: selected
              ? SnapFoodColors.softYellow
              : SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
                border: Border.all(
                  color: selected
                      ? SnapFoodColors.secondary
                      : SnapFoodColors.softBorder,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(SnapFoodSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.location_on_outlined,
                      color: selected
                          ? SnapFoodColors.secondary
                          : SnapFoodColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: SnapFoodSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: SnapFoodColors.warmBlack,
                                  ),
                                ),
                              ),
                              if (selected) ...[
                                const SizedBox(width: SnapFoodSpacing.sm),
                                const Text(
                                  'Selected',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: SnapFoodColors.secondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: SnapFoodSpacing.xs),
                          Text(
                            recipientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: SnapFoodColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: SnapFoodSpacing.xs),
                          Text(
                            addressLine,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: SnapFoodColors.warmBlack,
                            ),
                          ),
                          if (onEdit != null || onDelete != null) ...[
                            const SizedBox(height: SnapFoodSpacing.sm),
                            Wrap(
                              spacing: SnapFoodSpacing.xs,
                              children: [
                                if (onEdit != null)
                                  TextButton.icon(
                                    onPressed: onEdit,
                                    icon: const Icon(Icons.edit_outlined, size: 16),
                                    label: const Text('Edit'),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(48, 40),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: SnapFoodSpacing.sm,
                                      ),
                                      foregroundColor: SnapFoodColors.secondary,
                                    ),
                                  ),
                                if (onDelete != null)
                                  TextButton.icon(
                                    onPressed: onDelete,
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    label: const Text('Delete'),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(48, 40),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: SnapFoodSpacing.sm,
                                      ),
                                      foregroundColor: SnapFoodColors.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

/// Restaurant discovery card with metadata slots supplied by the feature layer.
///
/// The component intentionally does not own restaurant data or navigation. This
/// keeps rating, ETA, delivery fee and availability truthful to the API contract
/// that supplies them.
class SnapRestaurantCard extends StatelessWidget {
  const SnapRestaurantCard({
    required this.name,
    required this.image,
    this.rating,
    this.reviewCount,
    this.eta,
    this.deliveryMetadata,
    this.category,
    this.isOpen = true,
    this.onTap,
    this.width = 280,
    super.key,
  });

  final String name;
  final Widget image;
  final double? rating;
  final int? reviewCount;
  final String? eta;
  final String? deliveryMetadata;
  final String? category;
  final bool isOpen;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final radius = SnapFoodRadii.lg;
    final metadata = <Widget>[];

    if (rating != null) {
      metadata.add(
        SnapRatingBadge(
          rating: rating!.clamp(0, 5),
          reviewCount: reviewCount,
          compact: true,
        ),
      );
    }
    if (eta != null && eta!.trim().isNotEmpty) {
      metadata.add(_RestaurantMetadataChip(
        icon: Icons.schedule_rounded,
        label: eta!,
      ));
    }
    if (deliveryMetadata != null && deliveryMetadata!.trim().isNotEmpty) {
      metadata.add(_RestaurantMetadataChip(
        icon: Icons.two_wheeler_rounded,
        label: deliveryMetadata!,
      ));
    }

    return Semantics(
      container: true,
      label: '\$name\${rating == null ? '' : ', rated \${rating!.clamp(0, 5).toStringAsFixed(1)}'}\${eta == null ? '' : ', \$eta'}\${isOpen ? '' : ', currently closed'}',
      child: SizedBox(
        width: width,
        child: Material(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: SnapFoodColors.softBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 152,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        image,
                        Positioned(
                          left: SnapFoodSpacing.sm,
                          top: SnapFoodSpacing.sm,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: SnapFoodColors.surfaceContainerLowest.withAlpha(235),
                              borderRadius: BorderRadius.circular(SnapFoodRadii.full),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SnapFoodSpacing.sm,
                                vertical: SnapFoodSpacing.xs,
                              ),
                              child: Text(
                                isOpen ? 'Open' : 'Closed',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isOpen
                                      ? SnapFoodColors.warmBlack
                                      : SnapFoodColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SnapFoodSpacing.md,
                      SnapFoodSpacing.sm + SnapFoodSpacing.xs,
                      SnapFoodSpacing.md,
                      SnapFoodSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: SnapFoodColors.warmBlack,
                          ),
                        ),
                        if (category != null && category!.trim().isNotEmpty) ...[
                          const SizedBox(height: SnapFoodSpacing.xs),
                          Text(
                            category!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: SnapFoodColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (metadata.isNotEmpty) ...[
                          const SizedBox(height: SnapFoodSpacing.sm),
                          Wrap(
                            spacing: SnapFoodSpacing.xs,
                            runSpacing: SnapFoodSpacing.xs,
                            children: metadata,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RestaurantMetadataChip extends StatelessWidget {
  const _RestaurantMetadataChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainer,
          borderRadius: BorderRadius.circular(SnapFoodRadii.full),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SnapFoodSpacing.sm,
            vertical: SnapFoodSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: SnapFoodColors.secondary),
              const SizedBox(width: SnapFoodSpacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: SnapFoodColors.warmBlack,
                ),
              ),
            ],
          ),
        ),
      );
}
