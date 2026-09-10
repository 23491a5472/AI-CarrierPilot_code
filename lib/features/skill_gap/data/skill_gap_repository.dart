import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../services/gemini_service.dart';

final skillGapRepositoryProvider = Provider((ref) {
  return SkillGapRepository(ref.watch(supabaseClientProvider));
});

class SkillGapRepository {
  final SupabaseClient _supabase;
  final GeminiService _geminiService = GeminiService();

  SkillGapRepository(this._supabase);

  Future<Map<String, dynamic>> generateSkillGapReport(
    String resumeText,
    String jobDescription,
  ) async {
    final user = _supabase.auth.currentUser;
    Map<String, dynamic> result;

    try {
      final response = await _supabase.functions.invoke(
        'generate-skill-gap-report',
        body: {
          'resume_text': resumeText,
          'job_description': jobDescription,
        },
      );

      if (response.status == 200 && response.data != null) {
        result = Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Edge function fallback');
      }
    } catch (e) {
      result = await _geminiService.generateSkillGapReport(
        resumeText: resumeText,
        jobDescription: jobDescription,
      );
    }

    if (user != null) {
      try {
        await _supabase.from('skill_gap_reports').insert({
          'user_id': user.id,
          'gap_json': result,
        });
      } catch (e) {
        // Log db warning if RLS blocks
      }
    }

    return result;
  }
}
