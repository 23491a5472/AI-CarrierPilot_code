import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/auth_provider.dart';

final jobTrackerRepositoryProvider = Provider((ref) {
  return JobTrackerRepository(ref.watch(supabaseClientProvider));
});

class JobTrackerRepository {
  final SupabaseClient _supabase;

  JobTrackerRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getApplications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('saved_jobs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addApplication(Map<String, dynamic> data) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    data['user_id'] = userId;
    await _supabase.from('saved_jobs').insert(data);
  }
}
