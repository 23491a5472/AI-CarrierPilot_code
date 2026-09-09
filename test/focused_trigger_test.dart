import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

// ANSI Color Codes for terminal output
void pass(String msg) => print('\x1B[32m[PASS]\x1B[0m $msg');
void fail(String msg, [Object? e, StackTrace? st]) {
  print('\x1B[31m[FAIL]\x1B[0m $msg - ${e ?? ''}');
  if (st != null) print(st);
}

void main() async {
  print('=============================================');
  print('  Starting Focused Trigger Integration Test');
  print('=============================================\n');

  // Load Env
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    fail('Could not find .env file');
    return;
  }

  final envLines = envFile.readAsLinesSync();
  String? url;
  String? anonKey;
  String? serviceRoleKey;
  
  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.substring('SUPABASE_URL='.length).trim();
    if (line.startsWith('SUPABASE_ANON_KEY=')) anonKey = line.substring('SUPABASE_ANON_KEY='.length).trim();
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) serviceRoleKey = line.substring('SUPABASE_SERVICE_ROLE_KEY='.length).trim();
  }

  if (url == null || anonKey == null || serviceRoleKey == null) {
    fail('Missing URL, ANON_KEY, or SERVICE_ROLE_KEY in .env');
    return;
  }
  
  final supabaseAdmin = SupabaseClient(
    url, 
    serviceRoleKey,
    authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
  );
  
  // Test Variables
  final testPrefix = 'test_careerpilot_${DateTime.now().millisecondsSinceEpoch}';
  final email = '$testPrefix@careerpilot.local';
  final password = 'TestPassword123!';
  String? userId;

  try {
    print('--- TRIGGER TESTS ---');
    
    // 1. User Signup (via Admin API)
    try {
      final res = await supabaseAdmin.auth.admin.createUser(AdminUserAttributes(
        email: email, 
        password: password, 
        emailConfirm: true,
        userMetadata: {'full_name': 'Trigger Test User'}
      ));
      userId = res.user?.id;
      if (userId != null) {
        pass('1. New user signup ($email)');
      } else {
        fail('1. New user signup', 'No user ID returned');
        return;
      }
    } catch (e, st) {
      fail('1. New user signup', e, st);
      return;
    }

    // Helper to check for row creation
    Future<bool> checkRowExists(String table) async {
      try {
        final data = await supabaseAdmin.from(table).select().eq('user_id', userId!).maybeSingle();
        return data != null;
      } catch (e) {
        // Fallback for profiles which uses 'id' instead of 'user_id'
        if (table == 'profiles') {
          try {
            final data = await supabaseAdmin.from(table).select().eq('id', userId!).maybeSingle();
            return data != null;
          } catch (_) {}
        }
      }
      return false;
    }

    // Wait slightly to allow the DB trigger to finish
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. Profile Creation
    final hasProfile = await checkRowExists('profiles');
    hasProfile ? pass('2. Profile creation') : fail('2. Profile creation (Trigger did not insert profile)');

    // 3. Preferences Creation
    final hasPrefs = await checkRowExists('user_preferences');
    hasPrefs ? pass('3. Preferences creation') : fail('3. Preferences creation');

    // 4. Subscription Creation
    final hasSub = await checkRowExists('subscription_status');
    hasSub ? pass('4. Subscription creation') : fail('4. Subscription creation');

    // 5. Usage Limits Creation
    final hasLimits = await checkRowExists('user_usage_limits');
    hasLimits ? pass('5. Usage limits creation') : fail('5. Usage limits creation');

  } catch (e, st) {
    print('Unexpected error: $e');
    print(st);
  } finally {
    print('\n--- CLEANUP ---');
    if (userId != null) {
      try {
        // Safely wipe the dependent rows first using Admin privileges
        await supabaseAdmin.from('saved_jobs').delete().eq('user_id', userId);
        await supabaseAdmin.from('ats_analyses').delete().eq('user_id', userId);
        await supabaseAdmin.from('career_health_snapshots').delete().eq('user_id', userId);
        await supabaseAdmin.from('user_usage_limits').delete().eq('user_id', userId);
        await supabaseAdmin.from('subscription_status').delete().eq('user_id', userId);
        await supabaseAdmin.from('user_preferences').delete().eq('user_id', userId);
        await supabaseAdmin.from('profiles').delete().eq('id', userId);
        
        // Finally delete the user
        await supabaseAdmin.auth.admin.deleteUser(userId);
        pass('6. User deletion cleanup (Successfully wiped user and all data)');
      } catch (e) {
        fail('6. User deletion cleanup', e);
      }
    }
    
    print('\n=============================================');
    print('  Focused Trigger Test Finished');
    print('=============================================');
  }
}
