import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/inside_team_logo.dart';
import '../services/auth_service.dart';

/// Splash Screen that displays the InsideTeam brand mark, tagline,
/// geometric blueprint background, and transitions smoothly to login.
class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({
    super.key,
    required this.onInitializationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();

    // Initialize backend session and trigger navigation after short delay
    _initApp();
  }

  Future<void> _initApp() async {
    final stopwatch = Stopwatch()..start();
    await AuthService().initialize();
    stopwatch.stop();

    // Ensure a smooth, professional presentation (~1.6 seconds minimum)
    final remainingMs = 1600 - stopwatch.elapsedMilliseconds;
    final waitDuration = remainingMs > 0
        ? Duration(milliseconds: remainingMs)
        : const Duration(milliseconds: 300);

    _navigationTimer = Timer(waitDuration, () {
      if (mounted) {
        widget.onInitializationComplete();
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Stack(
        children: [
          // Subtle geometric / construction blueprint pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _BlueprintPatternPainter(),
            ),
          ),

          // Main brand content
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Prominent Brand Logo
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.teal.withValues(alpha: 0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const InsideTeamLogo(size: 96),
                        ),

                        const SizedBox(height: 28),

                        // Application Name
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Inside',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                color: AppColors.darkText,
                              ),
                            ),
                            Text(
                              'Team',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                color: AppColors.teal,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          'ENTERPRISE CONSTRUCTION MANAGEMENT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: AppColors.skyBlue.withValues(alpha: 0.9),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Official Tagline
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.borderLight,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            AppStrings.appTagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Smooth Loading Indicator
                        SizedBox(
                          width: 140,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: const LinearProgressIndicator(
                              minHeight: 4,
                              backgroundColor: Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.teal,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Initializing workspace...',
                          style: TextStyle(
                            fontSize: 12,
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
          ),
        ],
      ),
    );
  }
}

/// Subtle isometric grid / geometric construction line pattern for splash background
class _BlueprintPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 36.0;

    // Draw grid lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw decorative isometric crosshairs
    final crosshairPaint = Paint()
      ..color = AppColors.skyBlue.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final corners = [
      Offset(spacing * 2, spacing * 3),
      Offset(size.width - spacing * 2, spacing * 3),
      Offset(spacing * 2, size.height - spacing * 3),
      Offset(size.width - spacing * 2, size.height - spacing * 3),
    ];

    for (final pt in corners) {
      canvas.drawLine(Offset(pt.dx - 8, pt.dy), Offset(pt.dx + 8, pt.dy), crosshairPaint);
      canvas.drawLine(Offset(pt.dx, pt.dy - 8), Offset(pt.dx, pt.dy + 8), crosshairPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
