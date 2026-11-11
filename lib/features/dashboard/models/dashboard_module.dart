import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Representation of each navigation card on the Staff and Admin dashboards
class DashboardModule {
  final int id;
  final String title;
  final String shortCode;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color lightBackgroundColor;
  final bool isPlaceholder;
  final String? badgeText;

  const DashboardModule({
    required this.id,
    required this.title,
    required this.shortCode,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.lightBackgroundColor,
    this.isPlaceholder = false,
    this.badgeText,
  });

  /// The official 8 modules specified for InsideTeam
  static List<DashboardModule> get standardModules => [
        const DashboardModule(
          id: 1,
          title: 'Safety Training & Compliance Inspection',
          shortCode: 'MOD-01',
          description:
              'Safety training programs, site audits, hazard reporting, and regulatory compliance inspection management.',
          icon: Icons.health_and_safety_rounded,
          accentColor: AppColors.skyBlue,
          lightBackgroundColor: Color(0xFFF0F9FF),
        ),
        const DashboardModule(
          id: 2,
          title: 'SOP Verification Checklist',
          shortCode: 'MOD-02',
          description:
              'Standard Operating Procedure verification, daily digital site checklists, and quality sign-offs.',
          icon: Icons.checklist_rtl_rounded,
          accentColor: AppColors.teal,
          lightBackgroundColor: Color(0xFFF0FDF4),
        ),
        const DashboardModule(
          id: 3,
          title: 'Centralized Documentation Control System',
          shortCode: 'MOD-03',
          description:
              'Centralized construction blueprints, engineer drawings, permits, site memos, and revision archives.',
          icon: Icons.folder_shared_rounded,
          accentColor: AppColors.indigoAccent,
          lightBackgroundColor: Color(0xFFEEF2FF),
        ),
        const DashboardModule(
          id: 4,
          title: 'Budget Tracking Dashboard & Monthly Cost Review',
          shortCode: 'MOD-04',
          description:
              'Comprehensive project budgeting, milestone disbursements, expense variance, and monthly cost reviews.',
          icon: Icons.query_stats_rounded,
          accentColor: AppColors.warmAmber,
          lightBackgroundColor: Color(0xFFFFFBEB),
        ),
        const DashboardModule(
          id: 5,
          title: 'Subcontractor Summary & Performance Monitoring',
          shortCode: 'MOD-05',
          description:
              'Subcontractor directory, work order progress, safety compliance rating, and performance tracking.',
          icon: Icons.groups_2_rounded,
          accentColor: AppColors.softCoral,
          lightBackgroundColor: Color(0xFFFFF1F2),
        ),
        const DashboardModule(
          id: 6,
          title: 'Material Tracking & Procurement Monitoring System',
          shortCode: 'MOD-06',
          description:
              'On-site material inventory, purchase orders, delivery manifests, batch tests, and storage management.',
          icon: Icons.inventory_2_rounded,
          accentColor: AppColors.emeraldAccent,
          lightBackgroundColor: Color(0xFFECFDF5),
        ),
        const DashboardModule(
          id: 7,
          title: 'Equipment Maintenance Schedule',
          shortCode: 'MOD-07',
          description:
              'Machinery operating hours, preventive maintenance logs, inspection schedules, and breakdown reporting.',
          icon: Icons.build_circle_rounded,
          accentColor: AppColors.orangeAccent,
          lightBackgroundColor: Color(0xFFFFF7ED),
        ),
        const DashboardModule(
          id: 8,
          title: 'Future Module Placeholder',
          shortCode: 'MOD-08',
          description:
              'Additional construction engineering tools and site management capabilities currently in development pipeline.',
          icon: Icons.architecture_rounded,
          accentColor: AppColors.textMuted,
          lightBackgroundColor: Color(0xFFF1F5F9),
          isPlaceholder: true,
          badgeText: 'Coming Soon',
        ),
      ];
}
