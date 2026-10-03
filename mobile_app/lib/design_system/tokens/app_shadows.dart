import 'package:flutter/material.dart';

abstract final class SnapFoodShadows {
  static const level0 = <BoxShadow>[];

  static const level1 = <BoxShadow>[
    BoxShadow(
      blurRadius: 8,
      offset: Offset(0, 2),
      color: Color(0x14000000),
    ),
  ];

  static const level2 = <BoxShadow>[
    BoxShadow(
      blurRadius: 12,
      offset: Offset(0, 4),
      color: Color(0x1A000000),
    ),
  ];

  static const level3 = <BoxShadow>[
    BoxShadow(
      blurRadius: 20,
      offset: Offset(0, 8),
      color: Color(0x24000000),
    ),
  ];
}
