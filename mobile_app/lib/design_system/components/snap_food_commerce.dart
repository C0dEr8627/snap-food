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
