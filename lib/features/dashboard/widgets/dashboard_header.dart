import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../auth/models/user_profile.dart';

/// Top header section displaying personalized greeting, ID, role badge, avatar, and actions
class DashboardHeader extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onSignOut;

  const DashboardHeader({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active_rounded,
                        color: AppColors.teal),
                    SizedBox(width: 10),
                    Text(
                      'Site Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNotificationItem(
              icon: Icons.security_rounded,
              color: AppColors.skyBlue,
              title: 'Morning Safety Briefing Logged',
              time: 'Today • 08:00 AM',
              subtitle: 'Toolbox talk completed for Zone B steel fixers.',
            ),
            const Divider(height: 20, color: AppColors.borderLight),
            _buildNotificationItem(
              icon: Icons.checklist_rounded,
              color: AppColors.teal,
              title: 'SOP Verification Sign-off Required',
              time: 'Yesterday • 04:30 PM',
              subtitle:
                  'Foundation excavation checklist ready for engineer verification.',
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Live notifications will connect to Supabase Realtime in future phase.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSubtle,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: user.role.isAdmin
                      ? AppColors.warmAmber.withValues(alpha: 0.2)
                      : AppColors.skyBlue.withValues(alpha: 0.2),
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: user.role.isAdmin
                          ? const Color(0xFFB45309)
                          : const Color(0xFF0284C7),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.formattedId,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (user.department != null)
                        Text(
                          user.department!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSubtle,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildRoleBadge(user.role.displayName, user.role.isAdmin),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.borderLight),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline_rounded,
                  color: AppColors.darkText),
              title: const Text('My Profile & Security'),
              subtitle: const Text('Settings and account details (placeholder)'),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSubtle),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Profile management will be available in future phase.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  onSignOut();
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE2E2),
                  foregroundColor: AppColors.errorRed,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String roleLabel, bool isAdmin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? AppColors.adminBadgeBg : AppColors.staffBadgeBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings_rounded : Icons.badge_rounded,
            size: 13,
            color: isAdmin ? AppColors.adminBadgeText : AppColors.staffBadgeText,
          ),
          const SizedBox(width: 4),
          Text(
            roleLabel,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color:
                  isAdmin ? AppColors.adminBadgeText : AppColors.staffBadgeText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role.isAdmin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Avatar with role-colored outline
            GestureDetector(
              onTap: () => _showUserMenu(context),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isAdmin ? AppColors.warmAmber : AppColors.teal,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: isAdmin
                          ? AppColors.warmAmber.withValues(alpha: 0.18)
                          : AppColors.teal.withValues(alpha: 0.15),
                      child: Text(
                        user.initials,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isAdmin
                              ? const Color(0xFFB45309)
                              : const Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.emeraldAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Greeting, Name and ID
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Greeting, Name and Role badge adaptive row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_getGreeting()}, ${user.fullName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildRoleBadge(user.role.displayName, isAdmin),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.formattedId,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Notification Icon
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.darkText,
                    size: 24,
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.softCoral,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              tooltip: 'Notifications',
              onPressed: () => _showNotifications(context),
            ),

            // User Options Menu
            IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.darkText,
                size: 24,
              ),
              tooltip: 'Account Options',
              onPressed: () => _showUserMenu(context),
            ),
          ],
        ),
      ),
    );
  }
}
