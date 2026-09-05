import 'package:flutter/material.dart';

abstract final class AppColors {
  // Base backgrounds (Dark mode by default)
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF131A29);
  static const Color surfaceElevated = Color(0xFF1B2438);
  static const Color surfaceCard = Color(0xFF182032);
  static const Color border = Color(0xFF222F46);

  // Accents (Electric Emerald & Neon Cyan)
  static const Color primary = Color(0xFF00E599);
  static const Color primaryDark = Color(0xFF00B377);
  static const Color secondary = Color(0xFF38BDF8);
  static const Color accent = Color(0xFF818CF8);

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Feedback & Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Muscle group tags
  static const Color chest = Color(0xFFF43F5E);
  static const Color back = Color(0xFF0EA5E9);
  static const Color legs = Color(0xFF8B5CF6);
  static const Color shoulders = Color(0xFFF59E0B);
  static const Color arms = Color(0xFF10B981);
  static const Color core = Color(0xFFEC4899);
}
