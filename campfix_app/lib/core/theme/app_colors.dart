import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - deep indigo/blue
  static const Color primary = Color(0xFF2D4CC8);
  static const Color primaryDark = Color(0xFF1E37A0);
  static const Color primaryLight = Color(0xFF6B82E0);

  // Accent - teal/cyan
  static const Color accent = Color(0xFF14B8A6);
  static const Color accentLight = Color(0xFF5EEAD4);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Priority colors
  static const Color priorityLow = Color(0xFF64748B);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityCritical = Color(0xFFDC2626);

  // Neutrals - light theme
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // Text - light theme
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Neutrals - dark theme (prepared, not yet wired to a ThemeMode toggle)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}