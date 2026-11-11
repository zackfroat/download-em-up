import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../auth/models/user_profile.dart';
import '../models/dashboard_module.dart';
import '../screens/module_placeholder_screen.dart';
import '../../materials/screens/material_procurement_screen.dart';
import '../../documentation/screens/documentation_control_screen.dart';
import '../../sop/screens/sop_checklist_screen.dart';
import '../../equipment/screens/equipment_maintenance_screen.dart';
import '../../safety/screens/safety_training_screen.dart';
import '../../subcontractors/screens/subcontractor_summary_screen.dart';
import '../../budget/screens/budget_tracking_screen.dart';
import '../../../core/widgets/app_footer.dart';
import 'dashboard_header.dart';
import 'module_card.dart';

/// Reusable layout for both Staff and Admin dashboards conforming strictly
/// to the Original Enterprise design.
class DashboardBody extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onSignOut;
  final String roleBadgeTitle;
  final String summaryGreeting;
  final String summaryTagline;

  const DashboardBody({
    super.key,
    required this.user,
    required this.onSignOut,
    required this.roleBadgeTitle,
    required this.summaryGreeting,
    required this.summaryTagline,
  });

  @override
  Widget build(BuildContext context) {
    final modules = DashboardModule.standardModules;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        children: [
          // 1. Welcome header with name, ID, avatar, and role
          DashboardHeader(
            user: user,
            onSignOut: onSignOut,
          ),

          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Small summary section with welcome message & construction tagline
                      _buildSummarySection(),

                      const SizedBox(height: 24),

                      // 3. Section heading: "Your Workspace"
                      _buildSectionHeading(),

                      const SizedBox(height: 16),

                      // 4. The eight module cards in responsive grid
                      _buildModuleGrid(context, modules),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Locked/Sticky Footer at bottom of screen
          AppFooter(roleName: roleBadgeTitle),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final isAdmin = user.role.isAdmin;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAdmin
                  ? AppColors.warmAmber.withValues(alpha: 0.15)
                  : AppColors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isAdmin
                  ? Icons.corporate_fare_rounded
                  : Icons.engineering_rounded,
              color: isAdmin ? const Color(0xFFD97706) : AppColors.teal,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summaryGreeting,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summaryTagline,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.workspaceHeading,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          AppStrings.workspaceSubheading,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildModuleGrid(
    BuildContext context,
    List<DashboardModule> modules,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        double childAspectRatio = 0.98;

        if (constraints.maxWidth > 920) {
          crossAxisCount = 4;
          childAspectRatio = 1.05;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
          childAspectRatio = 1.02;
        } else {
          crossAxisCount = 2;
          childAspectRatio = constraints.maxWidth < 360
              ? 0.78
              : constraints.maxWidth < 420
                  ? 0.84
                  : 0.92;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final module = modules[index];
            return ModuleCard(
              module: module,
              onTap: () {
                if (module.id == 1) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SafetyTrainingScreen(
                        roleName: roleBadgeTitle,
                      ),
                    ),
                  );
                  return;
                }
                if (module.id == 2) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SopChecklistScreen(
                        roleName: roleBadgeTitle,
                      ),
                    ),
                  );
                  return;
                }
                if (module.id == 3) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DocumentationControlScreen(
                        roleName: roleBadgeTitle,
                      ),
                    ),
                  );
                  return;
                }
                if (module.id == 4) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BudgetTrackingScreen(
                        roleName: roleBadgeTitle,
                      ),
                    ),
                  );
                  return;
                }
                if (module.id == 5) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SubcontractorSummaryScreen(
                        roleName: roleBadgeTitle,
                      ),
                    ),
                  );
                  return;
                }
                if (module.id == 6) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MaterialProcurementScreen(
                        roleName: roleBadgeTitle,
                      ),
                    ),
                  );
                  return;
                }
                if (module.id == 7) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EquipmentMaintenanceScreen(
                        roleName: roleBadgeTitle,
                      ),
                    ),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ModulePlaceholderScreen(
                      module: module,
                      roleName: roleBadgeTitle,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
