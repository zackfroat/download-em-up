import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/inside_team_logo.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

/// Modern, responsive login screen for InsideTeam
class LoginScreen extends StatefulWidget {
  final Function(UserProfile user) onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Clear previous errors
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final authService = AuthService();
    final result = await authService.signIn(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess && result.user != null) {
      widget.onLoginSuccess(result.user!);
    } else {
      setState(() {
        _errorMessage = result.errorMessage ?? 'Authentication failed. Please verify your credentials.';
      });
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: AppColors.teal),
            SizedBox(width: 10),
            Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        content: const Text(
          'For security protocols on active construction projects, password reset requests are verified via your project supervisor or the site IT administrator.\n\nIn live Supabase deployment, a password reset link is securely dispatched to your registered email.',
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _prefillMockCredentials(String id, String password) {
    setState(() {
      _identifierController.text = id;
      _passwordController.text = password;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMockMode = AuthService().isUsingMockMode;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Brand Mark & Wordmark
                  const InsideTeamLogo(size: 68),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Inside',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        'Team',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  const Text(
                    AppStrings.appTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Login Card Container
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight, width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A0F172A),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.loginTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            AppStrings.loginSubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Error Message Banner (if any)
                          if (_errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFCA5A5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.errorRed,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF991B1B),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],

                          // Identifier Field (Email or Staff/Admin ID)
                          const Text(
                            AppStrings.emailOrIdLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _identifierController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: AppStrings.emailOrIdHint,
                              prefixIcon: Icon(
                                Icons.badge_outlined,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your Email or Staff/Admin ID';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // Password Field
                          const Text(
                            AppStrings.passwordLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            decoration: InputDecoration(
                              hintText: AppStrings.passwordHint,
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Forgot Password Placeholder Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                AppStrings.forgotPassword,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Login Button with Loading Feedback
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          AppStrings.loggingIn,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      AppStrings.loginButton,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Development Mock Mode Quick Test Helper (Clearly Labelled)
                  if (isMockMode) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.developer_mode_rounded,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'DEVELOPMENT TEST PRESETS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Click to auto-fill sample accounts. Role is determined strictly by the backend/database record upon login:',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _prefillMockCredentials(
                                    'D1CDIM2625C',
                                    'password123',
                                  ),
                                  icon: const Icon(
                                    Icons.badge_rounded,
                                    size: 14,
                                    color: AppColors.staffBadgeText,
                                  ),
                                  label: const Text(
                                    'Staff (Za Atizi)',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.staffBadgeText,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.staffBadgeBg,
                                    side: const BorderSide(
                                      color: Color(0xFFBAE6FD),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _prefillMockCredentials(
                                    'ADM9042A',
                                    'password123',
                                  ),
                                  icon: const Icon(
                                    Icons.admin_panel_settings_rounded,
                                    size: 14,
                                    color: AppColors.adminBadgeText,
                                  ),
                                  label: const Text(
                                    'Admin (Khairul)',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.adminBadgeText,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.adminBadgeBg,
                                    side: const BorderSide(
                                      color: Color(0xFFFDE68A),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Security notice footer
                  const Text(
                    'Protected by Role-Based Access Control (RBAC)',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}
