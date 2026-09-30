part of '../main.dart';

abstract final class AdminColors {
  static const ink = Color(0xFF201B17);
  static const muted = Color(0xFF4E4634);
  static const canvas = Color(0xFFFFF8F5);
  static const surface = Colors.white;
  static const line = Color(0xFFD1C5AE);
  static const yellow = Color(0xFFE4B935);
  static const yellowDark = Color(0xFF755B00);
  static const red = Color(0xFFD54126);
  static const redSoft = Color(0xFFFBE3DC);
  static const green = Color(0xFF2D7A4B);
  static const greenSoft = Color(0xFFE7F5EC);
  static const blue = Color(0xFF3867D6);
  static const blueSoft = Color(0xFFEAF0FF);
  static const amberSoft = Color(0xFFFFF4CE);
  static const peach = Color(0xFFF9EEE7);
  static const warning = Color(0xFFF05A3C);
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
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: fg)));
  }
}
