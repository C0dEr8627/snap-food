import 'package:flutter/material.dart';

abstract final class AdminMotion {
  static const navigation = Duration(milliseconds: 180);
  static const drawer = Duration(milliseconds: 230);
  static const hover = Duration(milliseconds: 120);
  static const dialog = Duration(milliseconds: 200);
  static const dataUpdate = Duration(milliseconds: 350);

  static const curve = Curves.easeOutCubic;
  static const easeOutCubic = Curves.easeOutCubic;
  static const emphasisCurve = Curves.easeInOutCubic;
}
