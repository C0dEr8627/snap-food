import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';

/// Branded search field used across customer discovery surfaces.
class SnapSearchField extends StatelessWidget {
  const SnapSearchField({
    required this.controller,
    this.hintText = 'Search dishes, restaurants...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.enabled = true,
    this.showMic = false,
    this.semanticLabel,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool enabled;
  final bool showMic;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;
    return Semantics(
      textField: true,
      label: semanticLabel ?? hintText,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        enabled: enabled,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: SnapFoodColors.warmBlack,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: SnapFoodColors.onSurfaceVariant,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 21,
            color: SnapFoodColors.warmBlack,
          ),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: 'Clear search',
                  onPressed: onClear ?? controller.clear,
                  icon: const Icon(Icons.close_rounded, size: 20),
                )
              : showMic
                  ? const Icon(
                      Icons.mic_none_rounded,
                      size: 20,
                      color: SnapFoodColors.onSurfaceVariant,
                    )
                  : null,
          filled: true,
          fillColor: SnapFoodColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SnapFoodSpacing.md,
            vertical: SnapFoodSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
            borderSide: const BorderSide(color: SnapFoodColors.softBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
            borderSide: const BorderSide(color: SnapFoodColors.softBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
            borderSide: const BorderSide(
              color: SnapFoodColors.secondary,
              width: 1.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
            borderSide: const BorderSide(color: SnapFoodColors.outlineVariant),
          ),
        ),
      ),
    );
  }
}

/// Compact selectable filter control with a clear selected state.
class SnapFilterChip extends StatelessWidget {
  const SnapFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? label,
      child: Material(
        color: selected
            ? SnapFoodColors.softYellow
            : SnapFoodColors.white,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected
                ? SnapFoodColors.secondary
                : SnapFoodColors.softBorder,
          ),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelected(!selected);
          },
          borderRadius: BorderRadius.circular(SnapFoodRadii.full),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SnapFoodSpacing.md,
                vertical: SnapFoodSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 17,
                      color: selected
                          ? SnapFoodColors.warmBlack
                          : SnapFoodColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: SnapFoodSpacing.sm),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? SnapFoodColors.warmBlack
                          : SnapFoodColors.onSurfaceVariant,
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

/// Category-specific chip with an optional leading icon.
class SnapCategoryChip extends StatelessWidget {
  const SnapCategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? label,
      child: Material(
        color: selected
            ? SnapFoodColors.primaryContainer
            : SnapFoodColors.white,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected
                ? SnapFoodColors.secondary
                : SnapFoodColors.softBorder,
          ),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelected();
          },
          borderRadius: BorderRadius.circular(SnapFoodRadii.full),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SnapFoodSpacing.md,
                vertical: SnapFoodSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 17,
                      color: selected
                          ? SnapFoodColors.warmBlack
                          : SnapFoodColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: SnapFoodSpacing.sm),
                  ],
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? SnapFoodColors.warmBlack
                          : SnapFoodColors.onSurfaceVariant,
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
