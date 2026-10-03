import 'package:flutter/material.dart';

abstract final class AdminShadows {
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 28,
      offset: Offset(0, 10),
    ),
  ];
}
