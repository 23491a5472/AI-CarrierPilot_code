import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/auth_provider.dart';

final coverLetterRepositoryProvider = Provider((ref) {
  return CoverLetterRepository(ref.watch(supabaseClientProvider));
});

class CoverLetterRepository {
  final SupabaseClient _supabase;

  CoverLetterRepository(this._supabase);

  Future<Map<String, dynamic>> generateCoverLetter(String resumeText, String jobDescription, String tone) async {
    final response = await _supabase.functions.invoke(
      'generate-cover-letter',
      body: {
        'resume_text': resumeText,
        'job_description': jobDescription,
        'tone': tone,
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to generate cover letter: ${response.error}');
    }

    return response.data as Map<String, dynamic>;
  }
}
