import 'package:flutter/material.dart';
import '../tokens/app_spacing.dart';

class SnapFoodConstrainedContent extends StatelessWidget {
  const SnapFoodConstrainedContent({required this.child, this.padding = const EdgeInsets.symmetric(horizontal: 16), super.key});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: SnapFoodSpacing.desktopMaxContentWidth),
      child: Padding(padding: padding, child: child),
    ),
  );
}
