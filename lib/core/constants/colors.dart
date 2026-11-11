import 'package:flutter/material.dart';

/// InsideTeam brand color palette and theme colors
class AppColors {
  AppColors._();

  // Primary brand palette from prompt
  static const Color skyBlue = Color(0xFF38BDF8);
  static const Color teal = Color(0xFF14B8A6);
  static const Color warmAmber = Color(0xFFFBBF24);
  static const Color softCoral = Color(0xFFFB7185);
  static const Color offWhite = Color(0xFFF8FAFC);
  static const Color darkText = Color(0xFF1E293B);

  // Supportive UI colors
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSubtle = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderCard = Color(0xFFEEF2F6);

  // Status & accent colors
  static const Color indigoAccent = Color(0xFF6366F1);
  static const Color emeraldAccent = Color(0xFF10B981);
  static const Color orangeAccent = Color(0xFFF97316);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);

  // Role badge colors
  static const Color staffBadgeBg = Color(0xFFE0F2FE); // Light sky blue
  static const Color staffBadgeText = Color(0xFF0369A1);
  static const Color adminBadgeBg = Color(0xFFFEF3C7); // Light amber
  static const Color adminBadgeText = Color(0xFFB45309);

  // Gradients for branding & cards
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFF0FDF4), Color(0xFFF8FAFC), Color(0xFFF0F9FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient logoShieldGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
