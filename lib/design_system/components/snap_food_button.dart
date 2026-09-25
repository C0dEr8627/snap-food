import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';

class SnapFoodPrimaryButton extends StatelessWidget {
  const SnapFoodPrimaryButton({required this.label, required this.onPressed, this.icon, super.key});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: FilledButton.icon(
      onPressed: onPressed, icon: icon == null ? const SizedBox.shrink() : Icon(icon), label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: SnapFoodColors.foodRed, foregroundColor: SnapFoodColors.onPrimary,
        textStyle: Theme.of(context).textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SnapFoodRadii.full)),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    ),
  );
}

class SnapFoodSecondaryButton extends StatelessWidget {
  const SnapFoodSecondaryButton({required this.label, required this.onPressed, super.key});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: SnapFoodColors.goldenYellow, foregroundColor: SnapFoodColors.warmBlack,
        textStyle: Theme.of(context).textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SnapFoodRadii.full)),
      ),
      child: Text(label),
    ),
  );
}
