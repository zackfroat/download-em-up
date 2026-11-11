import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'core/constants/strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/models/user_profile.dart';
import 'features/auth/models/user_role.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/dashboard/screens/admin_dashboard_screen.dart';
import 'features/dashboard/screens/staff_dashboard_screen.dart';
import 'features/dashboard/screens/unauthorized_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase client if environment credentials are supplied
  await SupabaseConfig.initialize();

  runApp(const InsideTeamApp());
}

/// Root Application Widget for InsideTeam
class InsideTeamApp extends StatefulWidget {
  const InsideTeamApp({super.key});

  @override
  State<InsideTeamApp> createState() => _InsideTeamAppState();
}

enum AppStage {
  splash,
  login,
  staffDashboard,
  adminDashboard,
  unauthorized,
}

class _InsideTeamAppState extends State<InsideTeamApp> {
  final AuthService _authService = AuthService();
  AppStage _currentStage = AppStage.splash;

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    // If user was signed out externally, return to login
    if (!_authService.isAuthenticated &&
        _currentStage != AppStage.splash &&
        _currentStage != AppStage.login) {
      setState(() {
        _currentStage = AppStage.login;
      });
    }
  }

  void _onSplashFinished() {
    final currentUser = _authService.currentUser;
    setState(() {
      if (currentUser != null) {
        // Auto-redirect to appropriate role dashboard
        _currentStage = currentUser.role == UserRole.admin
            ? AppStage.adminDashboard
            : AppStage.staffDashboard;
      } else {
        _currentStage = AppStage.login;
      }
    });
  }

  void _onLoginSuccess(UserProfile user) {
    setState(() {
      if (user.role == UserRole.admin) {
        _currentStage = AppStage.adminDashboard;
      } else {
        _currentStage = AppStage.staffDashboard;
      }
    });
  }

  Future<void> _onSignOut() async {
    await _authService.signOut();
    setState(() {
      _currentStage = AppStage.login;
    });
  }

  /// Strict Route Guard: Attempting to navigate to Admin
  void navigateToAdminRoute() {
    final user = _authService.currentUser;
    setState(() {
      if (user != null && user.role == UserRole.admin) {
        _currentStage = AppStage.adminDashboard;
      } else {
        // Enforce security: staff or unauthorized users are intercepted
        _currentStage = AppStage.unauthorized;
      }
    });
  }

  void navigateToStaffRoute() {
    setState(() {
      _currentStage = AppStage.staffDashboard;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _buildCurrentScreen(),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    final user = _authService.currentUser;

    switch (_currentStage) {
      case AppStage.splash:
        return SplashScreen(
          key: const ValueKey('splash_stage'),
          onInitializationComplete: _onSplashFinished,
        );

      case AppStage.login:
        return LoginScreen(
          key: const ValueKey('login_stage'),
          onLoginSuccess: _onLoginSuccess,
        );

      case AppStage.staffDashboard:
        if (user == null) {
          return LoginScreen(
            key: const ValueKey('login_fallback'),
            onLoginSuccess: _onLoginSuccess,
          );
        }
        return StaffDashboardScreen(
          key: const ValueKey('staff_stage'),
          user: user,
          onSignOut: _onSignOut,
        );

      case AppStage.adminDashboard:
        if (user == null) {
          return LoginScreen(
            key: const ValueKey('login_fallback'),
            onLoginSuccess: _onLoginSuccess,
          );
        }
        // Admin security guard
        return AdminDashboardScreen(
          key: const ValueKey('admin_stage'),
          user: user,
          onSignOut: _onSignOut,
          onNavigateToStaff: navigateToStaffRoute,
        );

      case AppStage.unauthorized:
        return UnauthorizedScreen(
          key: const ValueKey('unauthorized_stage'),
          onReturnToAuthorizedDashboard: navigateToStaffRoute,
          onSignOut: _onSignOut,
        );
    }
  }
}
