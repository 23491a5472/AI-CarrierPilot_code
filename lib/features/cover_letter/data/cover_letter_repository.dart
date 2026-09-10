import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../services/gemini_service.dart';

final coverLetterRepositoryProvider = Provider((ref) {
  return CoverLetterRepository(ref.watch(supabaseClientProvider));
});

class CoverLetterRepository {
  final SupabaseClient _supabase;
  final GeminiService _geminiService = GeminiService();

  CoverLetterRepository(this._supabase);

  Future<Map<String, dynamic>> generateCoverLetter(
    String resumeText,
    String jobDescription,
    String tone,
  ) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    Map<String, dynamic> result;

    try {
      final response = await _supabase.functions.invoke(
        'generate-cover-letter',
        body: {
          'resume_text': resumeText,
          'job_description': jobDescription,
          'tone': tone,
        },
      );

      if (response.status == 200 && response.data != null) {
        result = Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Edge function fallback');
      }
    } catch (e) {
      result = await _geminiService.generateCoverLetter(
        resumeText: resumeText,
        jobDescription: jobDescription,
        tone: tone,
      );
    }

    final letterText = result['cover_letter_text'] as String? ?? '';

    // Save record in cover_letters DB table
    try {
      await _supabase.from('cover_letters').insert({
        'user_id': user.id,
        'tone': tone,
        'content': letterText,
        'status': 'active',
      });

      // Increment usage count
      final limitsRes = await _supabase
          .from('user_usage_limits')
          .select('cover_letters_used_today')
          .eq('user_id', user.id)
          .maybeSingle();

      final currentUsed = limitsRes?['cover_letters_used_today'] as int? ?? 0;
      await _supabase
          .from('user_usage_limits')
          .update({'cover_letters_used_today': currentUsed + 1})
          .eq('user_id', user.id);
    } catch (e) {
      // Log db insert warning if RLS blocks
    }

    return result;
  }
}
