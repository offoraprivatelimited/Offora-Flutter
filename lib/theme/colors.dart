import 'package:flutter/material.dart';

class AppColors {
  // Brand palette: deep navy blue and warm gold
  static const Color darkBlue = Color(0xFF1F477D);
  static const Color brightGold = Color(0xFFF0B84D);
  static const Color darkerGold = Color(0xFFA3834D);

  static const Color primary = darkBlue;
  static const Color accent = brightGold;
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [darkBlue, Color(0xFF375E9A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FB);
  static const Color text = Color(0xFF0B1220);
}
