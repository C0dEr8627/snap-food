part of '../main.dart';

/// Snap Foodd's official brand palette. Keep admin UI accents within these
/// five brand colors; semantic colors below are aliases of the same palette.
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
}art of '../main.dart';

/// Snap Foodd's official brand palette. Keep admin UI accents within these
/// five brand colors; semantic colors below are aliases of the same palette.
abstract final class AdminColors {
  static const yellow = Color(0xFFF2D022);
  static const amber = Color(0xFFF2AE2E);
  static const redDark = Color(0xFFA61C1C);
  static const red = Color(0xFFD92929);
  static const ink = Color(0xFF0D0D0D);

  // Neutral structure and accessible text hierarchy.
  static const muted = Color(0xFF595959);
  static const canvas = Color(0xFFFFFDF3);
  static const surface = Colors.white;
  static const line = Color(0xFFE9E3CF);

  // Status colors remain brand-compliant (no green or blue accents).
  static const success = amber;
  static const warning = redDark;
  static const error = red;
  static const redSoft = Color(0x1AD92929);
  static const amberSoft = Color(0x1AF2AE2E);
  static const yellowSoft = Color(0x1AF2D022);
  static const green = amber;
  static const greenSoft = amberSoft;
  static const blue = redDark;
  static const blueSoft = redSoft;
  static const peach = Color(0x1AF2AE2E);
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

void _notice(BuildContext context, String message, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: error ? AdminColors.red : null, behavior: SnackBarBehavior.floating));

class AdminCard extends StatelessWidget {
  const AdminCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => shad.Card(
    filled: true,
    fillColor: AdminColors.surface,
    borderColor: AdminColors.line,
    borderRadius: BorderRadius.circular(14),
    borderWidth: 1,
    child: child,
  );
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    final Color bg = lower.contains('pending') || lower.contains('preparing') ? AdminColors.amberSoft : lower.contains('delivery') || lower.contains('approved') || lower.contains('available') || lower.contains('delivered') || lower.contains('ready') ? AdminColors.yellowSoft : lower.contains('offline') ? AdminColors.canvas : AdminColors.redSoft;
    final Color fg = lower.contains('pending') || lower.contains('preparing') ? AdminColors.redDark : lower.contains('delivery') || lower.contains('approved') || lower.contains('available') || lower.contains('delivered') || lower.contains('ready') ? AdminColors.redDark : lower.contains('offline') ? AdminColors.muted : AdminColors.red;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(fontSize: 12, height: 1.2, fontWeight: FontWeight.w700, color: fg)));
  }
}
