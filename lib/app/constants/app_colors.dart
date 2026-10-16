import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary Brand Colors
  static const Color primary = Color(0xFF5B67CA);
  static const Color primaryLight = Color(0xFF7E89EE);
  static const Color primaryDark = Color(0xFF3F4BA6);
  static const Color secondary = Color(0xFF2A2E43);
  static const Color accent = Color(0xFF6C63FF);

  // Background & Surface
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1E2432);
  static const Color textSecondary = Color(0xFF79819A);
  static const Color textLight = Color(0xFFA5ABC0);
  static const Color textWhite = Colors.white;

  // Status & Priority Colors
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityHighBg = Color(0xFFFFEBEE);
  static const Color priorityMedium = Color(0xFFFB8C00);
  static const Color priorityMediumBg = Color(0xFFFFF3E0);
  static const Color priorityLow = Color(0xFF43A047);
  static const Color priorityLowBg = Color(0xFFE8F5E9);

  static const Color completed = Color(0xFF2E7D32);
  static const Color completedBg = Color(0xFFE8F8EE);
  static const Color pending = Color(0xFFE65100);
  static const Color pendingBg = Color(0xFFFFF4E5);

  // UI Element Colors
  static const Color border = Color(0xFFE2E6F0);
  static const Color inputFill = Color(0xFFF5F6FA);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B67CA), Color(0xFF7E89EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF4A56C4), Color(0xFF6B78E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
