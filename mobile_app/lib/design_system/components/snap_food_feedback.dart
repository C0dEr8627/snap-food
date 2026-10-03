import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class SnapBottomSheet extends StatelessWidget {
  const SnapBottomSheet({
    required this.child,
    this.title,
    this.subtitle,
    this.padding,
    super.key,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: (padding ?? const EdgeInsets.fromLTRB(
          SnapFoodSpacing.mobileMargin,
          8,
          SnapFoodSpacing.mobileMargin,
          SnapFoodSpacing.lg,
        )).add(EdgeInsets.only(bottom: bottomInset)),
        child: Material(
          color: SnapFoodColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SnapFoodRadii.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: SnapFoodColors.softBorder,
                    borderRadius: BorderRadius.circular(SnapFoodRadii.full),
                  ),
                ),
              ),
              if (title != null) ...[
                Text(
                  title!,
                  style: SnapFoodTypography.sectionTitle,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: SnapFoodSpacing.xs),
                  Text(
                    subtitle!,
                    style: SnapFoodTypography.supporting,
                  ),
                ],
                const SizedBox(height: SnapFoodSpacing.md),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class SnapEmptyState extends StatelessWidget {
  const SnapEmptyState({
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 52 : 68,
          height: compact ? 52 : 68,
          decoration: BoxDecoration(
            color: SnapFoodColors.softYellow,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: compact ? 24 : 30,
            color: SnapFoodColors.warmBlack,
          ),
        ),
        SizedBox(height: compact ? SnapFoodSpacing.sm : SnapFoodSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: SnapFoodTypography.sectionTitle.copyWith(
            fontSize: compact ? 16 : 18,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: SnapFoodSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              message!,
              textAlign: TextAlign.center,
              style: SnapFoodTypography.supporting,
            ),
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: SnapFoodSpacing.md),
          FilledButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
        ],
      ],
    );

    return Semantics(
      container: true,
      label: message == null ? title : '$title. $message',
      child: Padding(
        padding: EdgeInsets.all(
          compact ? SnapFoodSpacing.md : SnapFoodSpacing.lg,
        ),
        child: content,
      ),
    );
  }
}

class SnapErrorState extends StatelessWidget {
  const SnapErrorState({
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.compact = false,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: true,
    label: '$title. $message',
    child: Padding(
      padding: EdgeInsets.all(
        compact ? SnapFoodSpacing.md : SnapFoodSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 48 : 60,
            height: compact ? 48 : 60,
            decoration: const BoxDecoration(
              color: SnapFoodColors.softRed,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.cloud_off_outlined,
              color: SnapFoodColors.secondary,
              size: 28,
            ),
          ),
          SizedBox(height: compact ? SnapFoodSpacing.sm : SnapFoodSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: SnapFoodTypography.sectionTitle.copyWith(
              fontSize: compact ? 16 : 18,
            ),
          ),
          const SizedBox(height: SnapFoodSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: SnapFoodTypography.supporting,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: SnapFoodSpacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(retryLabel),
            ),
          ],
        ],
      ),
    ),
  );
}

class SnapSkeleton extends StatefulWidget {
  const SnapSkeleton({
    this.width,
    this.height = 16,
    this.borderRadius = SnapFoodRadii.sm,
    this.margin,
    super.key,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  State<SnapSkeleton> createState() => _SnapSkeletonState();
}

class _SnapSkeletonState extends State<SnapSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: .45, end: .8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    }
    return AnimatedBuilder(
    animation: _opacity,
    builder: (context, child) => Opacity(
      opacity: _opacity.value,
      child: child,
    ),
    child: Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
    ),
  );
}

class SnapAlertDialog extends StatelessWidget {
  const SnapAlertDialog({
    required this.title,
    required this.message,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Confirm',
    this.onCancel,
    this.onConfirm,
    super.key,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: SnapFoodColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
    ),
    title: Text(title, style: SnapFoodTypography.sectionTitle),
    content: Text(message, style: SnapFoodTypography.body),
    actions: [
      TextButton(
        onPressed: onCancel ?? () => Navigator.of(context).pop(false),
        child: Text(cancelLabel),
      ),
      FilledButton(
        onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
        style: FilledButton.styleFrom(
          backgroundColor: SnapFoodColors.secondary,
          foregroundColor: SnapFoodColors.white,
        ),
        child: Text(confirmLabel),
      ),
    ],
  );
}

class SnapLoadingState extends StatelessWidget {
  const SnapLoadingState({
    this.message,
    this.skeleton,
    super.key,
  });

  final String? message;
  final Widget? skeleton;

  @override
  Widget build(BuildContext context) {
    if (skeleton != null) return skeleton!;

    return Semantics(
      container: true,
      liveRegion: true,
      label: message ?? 'Loading',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SnapFoodSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              if (message != null) ...[
                const SizedBox(height: SnapFoodSpacing.sm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: SnapFoodTypography.supporting,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
