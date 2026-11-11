import 'package:flutter/material.dart';
import '../../auth/models/user_profile.dart';
import '../widgets/dashboard_body.dart';

/// Staff Dashboard Screen
class StaffDashboardScreen extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onSignOut;

  const StaffDashboardScreen({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardBody(
      user: user,
      onSignOut: onSignOut,
      roleBadgeTitle: 'Staff',
      summaryGreeting: 'Welcome to your Site Operations Hub',
      summaryTagline: 'Build Safer. Work Smarter. Together.',
    );
  }
}
