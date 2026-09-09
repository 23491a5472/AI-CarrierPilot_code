import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/supabase_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(SupabaseService.client);
});

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail(String email, String password, String fullName) async {
    final response = await _client.auth.signUp(
      email: email, 
      password: password,
      data: {'full_name': fullName},
    );
    
    // The profile is automatically handled by auth.users (if using Supabase triggers)
    // or we can explicitly create the profile row here if no trigger is present.
    if (response.user != null) {
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
      }).select();
      
      // Initialize usage limits
      await _client.from('user_usage_limits').insert({
        'user_id': response.user!.id,
      });

      // Initialize default subscription
      await _client.from('subscription_status').insert({
        'user_id': response.user!.id,
      });

      // Initialize preferences
      await _client.from('user_preferences').insert({
        'user_id': response.user!.id,
      });
    }
    
    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
