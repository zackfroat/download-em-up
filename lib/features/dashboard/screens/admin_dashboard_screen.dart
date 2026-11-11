import 'package:flutter/material.dart';
import '../../auth/models/user_profile.dart';
import '../widgets/dashboard_body.dart';
import 'unauthorized_screen.dart';

/// Admin Dashboard Screen protected with strict role verification
class AdminDashboardScreen extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onSignOut;
  final VoidCallback onNavigateToStaff;

  const AdminDashboardScreen({
    super.key,
    required this.user,
    required this.onSignOut,
    required this.onNavigateToStaff,
  });

  @override
  Widget build(BuildContext context) {
    // Role Route Guard: Block non-admin users
    if (!user.role.isAdmin) {
      return UnauthorizedScreen(
        onReturnToAuthorizedDashboard: onNavigateToStaff,
        onSignOut: onSignOut,
      );
    }

    return DashboardBody(
      user: user,
      onSignOut: onSignOut,
      roleBadgeTitle: 'Admin',
      summaryGreeting: 'Project Directorate & Executive Overview',
      summaryTagline: 'Build Safer. Work Smarter. Together.',
    );
  }
}
