import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/auth_provider.dart';

final interviewRepositoryProvider = Provider((ref) {
  return InterviewRepository(ref.watch(supabaseClientProvider));
});

class InterviewRepository {
  final SupabaseClient _supabase;

  InterviewRepository(this._supabase);

  Future<Map<String, dynamic>> generateQuestions(String jobDescription) async {
    final response = await _supabase.functions.invoke(
      'generate-interview-questions',
      body: {
        'job_description': jobDescription,
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to generate interview questions: ${response.error}');
    }

    return response.data as Map<String, dynamic>;
  }
}
