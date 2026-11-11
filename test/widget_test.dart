import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insideteam/core/constants/strings.dart';
import 'package:insideteam/features/auth/services/auth_service.dart';
import 'package:insideteam/features/dashboard/models/dashboard_module.dart';
import 'package:insideteam/main.dart';

void main() {
  setUp(() async {
    // Reset auth state before each test
    await AuthService().signOut();
  });

  void setDeviceSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('InsideTeam app launches and displays splash screen', (WidgetTester tester) async {
    setDeviceSize(tester);
    await tester.pumpWidget(const InsideTeamApp());

    // Verify splash screen elements
    expect(find.text(AppStrings.appTagline), findsOneWidget);
    expect(find.text('ENTERPRISE CONSTRUCTION MANAGEMENT'), findsOneWidget);
    expect(find.text('Inside'), findsOneWidget);
    expect(find.text('Team'), findsOneWidget);
  });

  testWidgets('InsideTeam transitions from splash to login screen', (WidgetTester tester) async {
    setDeviceSize(tester);
    await tester.pumpWidget(const InsideTeamApp());

    // Advance timer past splash duration (~1.6s)
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify Login Screen is displayed
    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text(AppStrings.emailOrIdLabel), findsOneWidget);
    expect(find.text(AppStrings.passwordLabel), findsOneWidget);
    expect(find.text(AppStrings.loginButton), findsOneWidget);
    expect(find.text(AppStrings.forgotPassword), findsOneWidget);
  });

  testWidgets('Validation errors appear on empty login submission', (WidgetTester tester) async {
    setDeviceSize(tester);
    await tester.pumpWidget(const InsideTeamApp());
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    // Tap login button without filling fields
    final loginBtn = find.text(AppStrings.loginButton);
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    // Verify validation message
    expect(find.text('Please enter your Email or Staff/Admin ID'), findsOneWidget);
  });

  testWidgets('Staff login authenticates and redirects to Staff Dashboard with 8 modules', (WidgetTester tester) async {
    setDeviceSize(tester);
    await tester.pumpWidget(const InsideTeamApp());
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    // Tap preset button to prefill staff credentials
    final staffPresetBtn = find.text('Staff (Za Atizi)');
    await tester.ensureVisible(staffPresetBtn);
    await tester.tap(staffPresetBtn);
    await tester.pumpAndSettle();

    // Tap login button
    final loginBtn = find.text(AppStrings.loginButton);
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);

    // Let async mock auth complete
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Verify user is on Staff Dashboard with authenticated credentials
    expect(find.textContaining('Za Atizi Zainuddin'), findsWidgets);
    expect(find.text('Staff ID: D1CDIM2625C'), findsOneWidget);
    expect(find.text('Staff'), findsWidgets);
    expect(find.text(AppStrings.workspaceHeading), findsOneWidget);

    // Verify all 8 dashboard modules are rendered
    for (final module in DashboardModule.standardModules) {
      expect(find.text(module.title), findsOneWidget);
    }

    // Verify Coming Soon module card badge
    expect(find.text('Coming Soon'), findsOneWidget);
  });

  testWidgets('Admin login authenticates and redirects to Admin Dashboard', (WidgetTester tester) async {
    setDeviceSize(tester);
    await tester.pumpWidget(const InsideTeamApp());
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    // Tap preset button to prefill admin credentials
    final adminPresetBtn = find.text('Admin (Khairul)');
    await tester.ensureVisible(adminPresetBtn);
    await tester.tap(adminPresetBtn);
    await tester.pumpAndSettle();

    // Tap login button
    final loginBtn = find.text(AppStrings.loginButton);
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);

    // Let async mock auth complete
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Verify user is on Admin Dashboard with administrator identity
    expect(find.textContaining('Ir. Khairul Azhar'), findsWidgets);
    expect(find.text('Admin ID: ADM9042A'), findsOneWidget);
    expect(find.text('Admin'), findsWidgets);
    expect(find.text('Project Directorate & Executive Overview'), findsOneWidget);

    // Verify all 8 dashboard modules are present on admin dashboard
    for (final module in DashboardModule.standardModules) {
      expect(find.text(module.title), findsOneWidget);
    }
  });

  testWidgets('Module card navigation opens placeholder screen and returns', (WidgetTester tester) async {
    setDeviceSize(tester);
    await tester.pumpWidget(const InsideTeamApp());
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    // Log in as Staff
    final staffPresetBtn = find.text('Staff (Za Atizi)');
    await tester.ensureVisible(staffPresetBtn);
    await tester.tap(staffPresetBtn);
    await tester.pumpAndSettle();

    final loginBtn = find.text(AppStrings.loginButton);
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Tap the remaining pipeline placeholder module card: "Future Module Placeholder" (MOD-08)
    final placeholderModule = find.text('Future Module Placeholder');
    await tester.ensureVisible(placeholderModule);
    await tester.tap(placeholderModule);
    await tester.pumpAndSettle();

    // Verify Placeholder Screen is open
    expect(find.text('Development Phase Status'), findsOneWidget);
    expect(find.text('Back to Staff Dashboard'), findsOneWidget);

    // Tap return button
    final backBtn = find.text('Back to Staff Dashboard');
    await tester.ensureVisible(backBtn);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verify returned to Staff Dashboard
    expect(find.text(AppStrings.workspaceHeading), findsOneWidget);
  });
}
