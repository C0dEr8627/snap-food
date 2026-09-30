part of '../main.dart';

abstract final class AdminColors {
  static const ink = Color(0xFF18181B);
  static const muted = Color(0xFF71717A);
  static const canvas = Color(0xFFF7F7F8);
  static const surface = Colors.white;
  static const line = Color(0xFFE4E4E7);
  static const yellow = Color(0xFFFACC15);
  static const yellowDark = Color(0xFFA16207);
  static const red = Color(0xFFDC2626);
  static const redSoft = Color(0x1ADC2626);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0x1A16A34A);
  static const blue = Color(0xFF2563EB);
  static const blueSoft = Color(0x1A2563EB);
  static const amberSoft = Color(0x1AFACC15);
  static const peach = Color(0x1AF59E0B);
  static const warning = Color(0xFFA16207);
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
    fillColor: Colors.white,
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
    final Color bg = lower.contains('pending') || lower.contains('preparing') ? AdminColors.amberSoft : lower.contains('delivery') || lower.contains('approved') || lower.contains('available') || lower.contains('delivered') || lower.contains('ready') ? AdminColors.greenSoft : lower.contains('offline') ? AdminColors.canvas : AdminColors.blueSoft;
    final Color fg = lower.contains('pending') || lower.contains('preparing') ? AdminColors.yellowDark : lower.contains('delivery') || lower.contains('approved') || lower.contains('available') || lower.contains('delivered') || lower.contains('ready') ? AdminColors.green : lower.contains('offline') ? AdminColors.muted : AdminColors.blue;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(fontSize: 12, height: 1.2, fontWeight: FontWeight.w700, color: fg)));
  }
}
