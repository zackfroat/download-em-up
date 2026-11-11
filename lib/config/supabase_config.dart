import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuration and initializer for Supabase client
class SupabaseConfig {
  SupabaseConfig._();

  // You can inject these at compile/runtime using:
  // --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=ey...
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Checks if valid Supabase credentials have been configured
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('YOUR_PROJECT') &&
      supabaseUrl.startsWith('https://');

  /// Initialize Supabase if configured, otherwise logs notice
  static Future<bool> initialize() async {
    if (!isConfigured) {
      debugPrint(
        'ℹ️ [InsideTeam] Supabase is not yet configured. Running in Development Mock Mode.\n'
        '   To connect real Supabase, supply SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
      return false;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      debugPrint('✅ [InsideTeam] Supabase initialized successfully.');
      return true;
    } catch (e) {
      debugPrint('⚠️ [InsideTeam] Failed to initialize Supabase: $e');
      return false;
    }
  }

  /// The PostgreSQL Schema & RLS Policies required in Supabase
  static const String sqlSchema = '''
-- 1. Create User Profiles table in public schema
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  employee_id TEXT NOT NULL UNIQUE, -- Staff ID or Admin ID
  role TEXT NOT NULL CHECK (role IN ('staff', 'admin')),
  department TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies
-- Users can view their own profile
CREATE POLICY "Users can read own profile"
  ON public.user_profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Only Admins can view all profiles
CREATE POLICY "Admins can view all profiles"
  ON public.user_profiles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Only Admins can update profiles (including roles)
CREATE POLICY "Admins can update profiles"
  ON public.user_profiles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- 4. Automatic profile creation trigger on Auth signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS \$\$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, employee_id, role, department)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', 'New Team Member'),
    COALESCE(new.raw_user_meta_data->>'employee_id', 'IT-' || substring(new.id::text from 1 for 6)),
    COALESCE(new.raw_user_meta_data->>'role', 'staff'),
    new.raw_user_meta_data->>'department'
  );
  RETURN NEW;
END;
\$\$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
''';
}
