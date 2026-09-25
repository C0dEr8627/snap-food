import 'package:flutter/widgets.dart';
import '../tokens/app_breakpoints.dart';

enum SnapFoodWindowClass { compact, medium, expanded }

extension SnapFoodWindowClassX on SnapFoodWindowClass {
  bool get isCompact => this == SnapFoodWindowClass.compact;
  bool get isMedium => this == SnapFoodWindowClass.medium;
  bool get isExpanded => this == SnapFoodWindowClass.expanded;
}

SnapFoodWindowClass windowClassForWidth(double width) {
  if (width <= SnapFoodBreakpoints.compactMax) return SnapFoodWindowClass.compact;
  if (width <= SnapFoodBreakpoints.mediumMax) return SnapFoodWindowClass.medium;
  return SnapFoodWindowClass.expanded;
}

class SnapFoodResponsive extends StatelessWidget {
  const SnapFoodResponsive({required this.compact, this.medium, this.expanded, super.key});
  final Widget compact;
  final Widget? medium;
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    final type = windowClassForWidth(MediaQuery.sizeOf(context).width);
    if (type.isExpanded && expanded != null) return expanded!;
    if (type.isMedium && medium != null) return medium!;
    return compact;
  }
}
