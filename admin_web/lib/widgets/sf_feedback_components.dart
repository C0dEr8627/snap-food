part of '../main.dart';

class SfFeedback {
  static void showSuccess(BuildContext context, String message) =>
      _show(context, message, AdminDesignColors.success, HugeIcons.strokeRoundedCheckmarkCircle02);

  static void showError(BuildContext context, String message) =>
      _show(context, message, AdminDesignColors.error, HugeIcons.strokeRoundedAlert02);

  static void showInfo(BuildContext context, String message) =>
      _show(context, message, AdminDesignColors.info, HugeIcons.strokeRoundedInformationCircle);

  static void _show(BuildContext context, String message, Color color, AdminIconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AdminSpacing.lg),
          backgroundColor: AdminDesignColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminRadii.control),
            side: BorderSide(color: AdminDesignColors.border),
          ),
          content: Row(
            children: [
              AdminIcon(icon, size: 20, color: color),
              const SizedBox(width: AdminSpacing.sm),
              Expanded(
                child: Text(message, style: AdminTypography.body.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
  }
}

class SfConfirmDialog extends StatelessWidget {
  const SfConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => SfConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title, style: AdminTypography.sectionTitle),
    content: Text(message, style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText)),
    actions: [
      SfButton(
        variant: SfButtonVariant.ghost,
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(cancelLabel),
      ),
      SfButton(
        variant: destructive ? SfButtonVariant.destructive : SfButtonVariant.primary,
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(confirmLabel),
      ),
    ],
  );
}

class SfSideDrawer extends StatelessWidget {
  const SfSideDrawer({
    super.key,
    required this.title,
    required this.child,
    this.width = 440,
  });

  final String title;
  final Widget child;
  final double width;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    double width = 440,
  }) => showGeneralDialog<T>(
    context: context,
    barrierLabel: title,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionDuration: AdminMotion.drawer,
    pageBuilder: (_, __, ___) => Align(
      alignment: Alignment.centerRight,
      child: SfSideDrawer(title: title, child: child, width: width),
    ),
    transitionBuilder: (_, animation, __, child) => SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: AdminMotion.easeOutCubic),
      ),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) => Material(
    color: AdminDesignColors.surface,
    child: SizedBox(
      width: width,
      height: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AdminSpacing.lg),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: AdminTypography.sectionTitle)),
                  SfIconButton(
                    icon: HugeIcons.strokeRoundedCancel01,
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AdminSpacing.lg),
                child: child,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
