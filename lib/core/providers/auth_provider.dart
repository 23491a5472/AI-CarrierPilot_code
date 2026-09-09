import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provides the single instance of Supabase Client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Stream of Auth State Changes
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange;
});

// Provides the currently logged-in user, or null
final currentUserProvider = Provider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.currentUser;
});
