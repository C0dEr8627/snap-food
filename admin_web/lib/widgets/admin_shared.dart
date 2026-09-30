part of '../main.dart';

abstract final class AdminColors {
  static const ink = Color(0xFF0D0D0D);
  static const muted = Color(0xFF4A4A4A);
  static const canvas = Color(0x14F2D022);
  static const surface = Colors.white;
  static const line = Color(0xFFB7B7B7);
  static const yellow = Color(0xFFF2D022);
  static const yellowDark = Color(0xFFA61C1C);
  static const red = Color(0xFFD92929);
  static const redSoft = Color(0x1AD92929);
  static const green = Color(0xFF7A5A00);
  static const greenSoft = Color(0x1AF2AE2E);
  static const blue = Color(0xFF0D0D0D);
  static const blueSoft = Color(0x14F2D022);
  static const amberSoft = Color(0x33F2D022);
  static const peach = Color(0x1AF2AE2E);
  static const warning = Color(0xFF7A5A00);
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
