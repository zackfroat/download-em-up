import 'package:flutter/material.dart';

/// Available design theme for the InsideTeam dashboard (Original Enterprise)
enum DashboardThemeMode {
  originalEnterprise,
}

extension DashboardThemeDetails on DashboardThemeMode {
  String get displayName => 'Original Enterprise';
  String get description =>
      'Clean minimalist cards, subtle soft shadows, and corporate typography.';
  IconData get icon => Icons.business_center_rounded;
  Color get previewColor => const Color(0xFF0F766E);
}

/// Global observable Theme Controller pinned to Original Enterprise
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  DashboardThemeMode get currentTheme => DashboardThemeMode.originalEnterprise;

  void setTheme(DashboardThemeMode theme) {
    // Locked to Original Enterprise
  }
}
