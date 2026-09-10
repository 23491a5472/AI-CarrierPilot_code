import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../services/gemini_service.dart';

final interviewRepositoryProvider = Provider((ref) {
  return InterviewRepository(ref.watch(supabaseClientProvider));
});

class InterviewRepository {
  final SupabaseClient _supabase;
  final GeminiService _geminiService = GeminiService();

  InterviewRepository(this._supabase);

  Future<Map<String, dynamic>> generateQuestions({
    required String targetRole,
    String? experienceLevel,
    String? resumeText,
    String? jobDescription,
    String? category,
  }) async {
    final user = _supabase.auth.currentUser;
    Map<String, dynamic> result;

    try {
      final response = await _supabase.functions.invoke(
        'generate-interview-questions',
        body: {
          'target_role': targetRole,
          'experience_level': experienceLevel ?? 'Intermediate',
          'resume_text': resumeText,
          'job_description': jobDescription,
          'category': category,
        },
      );

      if (response.status == 200 && response.data != null) {
        result = Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Edge function fallback');
      }
    } catch (e) {
      result = await _geminiService.generateInterviewQuestions(
        targetRole: targetRole,
        experienceLevel: experienceLevel,
        resumeText: resumeText,
        jobDescription: jobDescription,
        category: category,
      );
    }

    if (user != null) {
      try {
        await _supabase.from('interview_questions').insert({
          'user_id': user.id,
          'category': category ?? 'Role Specific',
          'questions_json': result,
        });
      } catch (e) {
        // Log db warning if RLS blocks
      }
    }

    return result;
  }
}
