part of '../main.dart';

/// Snap Foodd's centralized admin color aliases.
abstract final class AdminColors {
  static const yellow = AdminDesignColors.brandYellow;
  static const amber = AdminDesignColors.brandAmber;
  static const redDark = AdminDesignColors.deepRed;
  static const red = AdminDesignColors.foodRed;
  static const ink = AdminDesignColors.ink;

  static const muted = AdminDesignColors.secondaryText;
  static const canvas = AdminDesignColors.canvas;
  static const surface = AdminDesignColors.surface;
  static const line = AdminDesignColors.border;

  static const success = AdminDesignColors.success;
  static const warning = AdminDesignColors.warning;
  static const error = AdminDesignColors.error;
  static const info = AdminDesignColors.info;

  static const redSoft = AdminDesignColors.redSoft;
  static const amberSoft = AdminDesignColors.amberSoft;
  static const yellowSoft = AdminDesignColors.yellowSoft;
  static const green = AdminDesignColors.success;
  static const greenSoft = AdminDesignColors.successSoft;
  static const blue = AdminDesignColors.info;
  static const blueSoft = AdminDesignColors.infoSoft;
  static const peach = AdminDesignColors.amberSoft;
}

typedef AdminIconData = List<List>;

class AdminIcon extends StatelessWidget {
  const AdminIcon(this.icon, {super.key, this.size = 24, this.color, this.strokeWidth = 1.8});

  final AdminIconData icon;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => HugeIcon(
    icon: icon,
    size: size,
    color: color ?? DefaultTextStyle.of(context).style.color,
    strokeWidth: strokeWidth,
  );
}

void _notice(BuildContext context, String message, {bool error = false}) {
  if (error) {
    SfFeedback.showError(context, message);
  } else {
    SfFeedback.showInfo(context, message);
  }
}

class AdminCard extends StatelessWidget {
  const AdminCard({super.key, required this.child, this.padding = const EdgeInsets.all(AdminSpacing.lg)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => SfCard(child: child, padding: padding);
}

