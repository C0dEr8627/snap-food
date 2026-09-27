import 'package:flutter/material.dart';
import '../../../design_system/components/snap_food_button.dart';
import '../../../design_system/layout/constrained_content.dart';
import '../../../design_system/layout/responsive.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_spacing.dart';

class FoundationPreviewScreen extends StatelessWidget {
  const FoundationPreviewScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SnapFoodConstrainedContent(
        padding: const EdgeInsets.all(SnapFoodSpacing.mobileMargin),
        child: SnapFoodResponsive(
          compact: _preview(context, false),
          medium: _preview(context, true),
          expanded: _preview(context, true),
        ),
      ),
    ),
  );

  Widget _preview(BuildContext context, bool wide) {
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
        width: wide ? 760 : double.infinity,
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(wide ? 40 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 56, height: 56, decoration: const BoxDecoration(color: SnapFoodColors.goldenYellow, shape: BoxShape.circle), child: const Icon(Icons.restaurant, color: SnapFoodColors.warmBlack)),
                const SizedBox(height: 24),
                Text('Snap Fooddd', style: theme.textTheme.displaySmall),
                const SizedBox(height: 8),
                Text('Frontend foundation is ready.', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Development checkpoint for the cross-platform Flutter foundation. The first Stitch screen will replace this preview in the next milestone.', style: theme.textTheme.bodyMedium?.copyWith(color: SnapFoodColors.onSurfaceVariant)),
                const SizedBox(height: 24),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  SnapFoodPrimaryButton(label: 'Foundation ready', onPressed: () {}),
                  SnapFoodSecondaryButton(label: wide ? 'Expanded layout' : 'Compact layout', onPressed: () {}),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
