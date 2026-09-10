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
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('saved_jobs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> addApplication({
    required String title,
    required String company,
    String? location,
    String? salaryRange,
    String status = 'Applied',
    int matchPercentage = 85,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final payload = {
      'user_id': userId,
      'title': title,
      'company': company,
      'location': location ?? 'Remote',
      'salary_range': salaryRange ?? '\$120k - \$160k',
      'status': status,
      'match_percentage': matchPercentage,
    };

    try {
      await _supabase.from('saved_jobs').insert(payload);
    } catch (_) {
      // Fallback if status column is omitted in legacy schema
      await _supabase.from('saved_jobs').insert({
        'user_id': userId,
        'title': title,
        'company': company,
        'location': location ?? 'Remote',
        'salary_range': salaryRange ?? '\$120k - \$160k',
        'match_percentage': matchPercentage,
      });
    }
  }

  Future<void> updateStatus(String id, String status) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    try {
      await _supabase
          .from('saved_jobs')
          .update({'status': status})
          .eq('id', id)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> deleteApplication(String id) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('saved_jobs')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
