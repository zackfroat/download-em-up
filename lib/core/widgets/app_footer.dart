import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';

/// Standard sticky bottom footer displaying InsideTeam branding and role information.
/// Locks at the bottom of the screen across all application pages.
class AppFooter extends StatelessWidget {
  final String? roleName;

  const AppFooter({
    super.key,
    this.roleName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.companyFooter,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSubtle,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              roleName != null && roleName!.isNotEmpty
                  ? 'Enterprise Edition • Role: $roleName'
                  : 'Enterprise Edition',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSubtle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

