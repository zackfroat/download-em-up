import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/supabase_config.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';

/// Authentication result wrapper
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final UserProfile? user;

  const AuthResult.success(this.user)
      : isSuccess = true,
        errorMessage = null;

  const AuthResult.failure(this.errorMessage)
      : isSuccess = false,
        user = null;
}

/// Authentication Service with support for both Supabase production backend
/// and a clearly labelled development-only mock authentication provider.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserProfile? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isUsingMockMode => !SupabaseConfig.isConfigured;

  /// Development Mock Accounts (Strictly for local development and UI testing)
  /// In production, all credentials and roles reside in Supabase Auth & PostgreSQL.
  static final List<Map<String, dynamic>> _devMockDatabase = [
    {
      'id': 'mock-uuid-staff-001',
      'email': 'staff@insideteam.com',
      'password': 'password123',
      'full_name': 'Za Atizi Zainuddin',
      'employee_id': 'D1CDIM2625C',
      'role': 'staff',
      'department': 'Safety & Compliance Division',
      'avatar_url': null,
    },
    {
      'id': 'mock-uuid-admin-002',
      'email': 'admin@insideteam.com',
      'password': 'password123',
      'full_name': 'Ir. Khairul Azhar',
      'employee_id': 'ADM9042A',
      'role': 'admin',
      'department': 'Project Directorate & Operations',
      'avatar_url': null,
    },
  ];

  /// Initialize auth state from existing session if available
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (SupabaseConfig.isConfigured) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null && session.user.id.isNotEmpty) {
          await _fetchProfileFromSupabase(session.user.id, session.user.email);
        }
      }
    } catch (e) {
      debugPrint('Error restoring Supabase session: $e');
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Sign in with email or Employee ID and password.
  /// Resolves the user's role exclusively from the trusted backend database record.
  Future<AuthResult> signIn({
    required String identifier, // Email or Staff/Admin ID
    required String password,
  }) async {
    final cleanId = identifier.trim();
    final cleanPassword = password.trim();

    if (cleanId.isEmpty) {
      return const AuthResult.failure('Please enter your email or Staff/Admin ID.');
    }
    if (cleanPassword.isEmpty) {
      return const AuthResult.failure('Please enter your password.');
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (SupabaseConfig.isConfigured) {
        return await _signInWithSupabase(cleanId, cleanPassword);
      } else {
        return await _signInWithMockDatabase(cleanId, cleanPassword);
      }
    } catch (e) {
      return AuthResult.failure('Authentication error: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supabase Backend Authentication Flow
  Future<AuthResult> _signInWithSupabase(String identifier, String password) async {
    final client = Supabase.instance.client;

    // Resolve email if user entered employee ID instead
    String emailToUse = identifier;
    if (!identifier.contains('@')) {
      try {
        final lookup = await client
            .from('user_profiles')
            .select('email')
            .eq('employee_id', identifier.toUpperCase())
            .maybeSingle();

        if (lookup != null && lookup['email'] != null) {
          emailToUse = lookup['email'];
        } else {
          return const AuthResult.failure('No account found with this Staff/Admin ID.');
        }
      } catch (e) {
        return AuthResult.failure('ID lookup failed: $e');
      }
    }

    // Authenticate through Supabase Auth
    try {
      final response = await client.auth.signInWithPassword(
        email: emailToUse,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const AuthResult.failure('Authentication failed. Please verify your credentials.');
      }

      final profile = await _fetchProfileFromSupabase(user.id, user.email);
      if (profile != null) {
        _currentUser = profile;
        return AuthResult.success(profile);
      } else {
        return const AuthResult.failure('User profile record not found in database.');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('Sign in failed: $e');
    }
  }

  /// Fetch profile from Supabase PostgreSQL table
  Future<UserProfile?> _fetchProfileFromSupabase(String userId, String? fallbackEmail) async {
    try {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = UserProfile.fromMap(response, fallbackEmail: fallbackEmail);
      _currentUser = profile;
      return profile;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  /// Development Mock Authentication Mode
  /// Simulates realistic backend latency, credential verification, and database role retrieval.
  Future<AuthResult> _signInWithMockDatabase(String identifier, String password) async {
    // Simulate network roundtrip
    await Future.delayed(const Duration(milliseconds: 650));

    final normalizedId = identifier.trim().toLowerCase();

    // Find user record by email or employee ID
    final match = _devMockDatabase.firstWhere(
      (record) =>
          record['email'].toString().toLowerCase() == normalizedId ||
          record['employee_id'].toString().toLowerCase() == normalizedId,
      orElse: () => {},
    );

    if (match.isEmpty) {
      return const AuthResult.failure(
        'Invalid credentials. No account found for this Email or Staff/Admin ID.',
      );
    }

    if (match['password'] != password) {
      return const AuthResult.failure('Incorrect password. Please try again.');
    }

    // Securely construct UserProfile from the database record
    final profile = UserProfile.fromMap(match);
    _currentUser = profile;
    return AuthResult.success(profile);
  }

  /// Sign out and clear active session
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (SupabaseConfig.isConfigured) {
        await Supabase.instance.client.auth.signOut();
      }
    } catch (e) {
      debugPrint('Error during Supabase signOut: $e');
    } finally {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Role security guard: Checks if the current authenticated user has Admin role
  bool canAccessAdmin() {
    return _currentUser != null && _currentUser!.role == UserRole.admin;
  }
}
