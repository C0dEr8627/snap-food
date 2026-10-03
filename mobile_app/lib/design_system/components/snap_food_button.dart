import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';

/// Branded primary conversion control.
class SnapPrimaryButton extends StatelessWidget {
  const SnapPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel ?? label,
      child: SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: SnapFoodColors.foodRed,
            foregroundColor: SnapFoodColors.onPrimary,
            disabledBackgroundColor: SnapFoodColors.outlineVariant,
            disabledForegroundColor: SnapFoodColors.onSurfaceVariant,
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SnapFoodRadii.full),
            ),
            padding: const EdgeInsets.symmetric(horizontal: SnapFoodSpacing.xl),
          ),
          child: _content(context),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (loading) {
      return const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    }
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
    );
  }
}

/// Branded secondary action control for highlights and selections.
class SnapSecondaryButton extends StatelessWidget {
  const SnapSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: SnapFoodColors.goldenYellow,
          foregroundColor: SnapFoodColors.warmBlack,
          disabledBackgroundColor: SnapFoodColors.outlineVariant,
          disabledForegroundColor: SnapFoodColors.onSurfaceVariant,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SnapFoodRadii.full),
          ),
          padding: const EdgeInsets.symmetric(horizontal: SnapFoodSpacing.xl),
        ),
        child: loading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : icon == null
                ? Text(label)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Text(label),
                    ],
                  ),
      ),
    );
  }
}

/// Small utility control with a branded, accessible hit area.
class SnapIconButton extends StatelessWidget {
  const SnapIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.selected = false,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool selected;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? tooltip,
      child: IconButton(
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onPressed?.call();
              },
        tooltip: tooltip,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: selected
              ? SnapFoodColors.foodRed
              : SnapFoodColors.warmBlack,
          backgroundColor: selected
              ? SnapFoodColors.softRed
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SnapFoodRadii.md),
          ),
        ),
      ),
    );
  }
}

/// Compact add-to-cart conversion control used on catalogue surfaces.
class SnapAddToCartButton extends StatelessWidget {
  const SnapAddToCartButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final canPress = enabled && !loading && onPressed != null;
    return Semantics(
      button: true,
      enabled: canPress,
      label: label,
      child: SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: canPress ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: SnapFoodColors.foodRed,
            foregroundColor: SnapFoodColors.onPrimary,
            disabledBackgroundColor: SnapFoodColors.outlineVariant,
            disabledForegroundColor: SnapFoodColors.onSurfaceVariant,
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: SnapFoodSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SnapFoodRadii.full),
            ),
          ),
          child: loading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
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

/// Backwards-compatible aliases for existing customer screens.
typedef SnapFoodPrimaryButton = SnapPrimaryButton;
typedef SnapFoodSecondaryButton = SnapSecondaryButton;
