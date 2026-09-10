import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../services/gemini_service.dart';

final analyzeRepositoryProvider = Provider((ref) {
  return AnalyzeRepository(ref.watch(supabaseClientProvider));
});

class AnalyzeRepository {
  final SupabaseClient _supabase;
  final GeminiService _geminiService = GeminiService();

  AnalyzeRepository(this._supabase);

  Future<String> uploadResume(File file) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final path = '$userId/$fileName';

    await _supabase.storage.from('resumes').upload(path, file);
    return path;
  }

  Future<Map<String, dynamic>> analyzeResume(String resumeTextOrPath, String jobDescription) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    Map<String, dynamic> analysisResult;

    try {
      // 1. Try invoking Edge Function
      final response = await _supabase.functions.invoke(
        'analyze-resume',
        body: {
          'resume_text': resumeTextOrPath,
          'job_description': jobDescription,
        },
      );

      if (response.status == 200 && response.data != null) {
        analysisResult = Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Edge function fallback');
      }
    } catch (e) {
      // 2. Direct Gemini service execution
      analysisResult = await _geminiService.analyzeResume(
        resumeText: resumeTextOrPath,
        jobDescription: jobDescription,
      );
    }

    final atsScore = (analysisResult['ats_score'] as num? ?? 80).toInt();

    // 3. Insert record into ats_analyses table
    try {
      await _supabase.from('ats_analyses').insert({
        'user_id': user.id,
        'status': 'completed',
        'ats_score': atsScore,
        'analysis_json': analysisResult,
      });

      // 4. Update career_health_snapshots
      await _supabase.from('career_health_snapshots').insert({
        'user_id': user.id,
        'ats_score': atsScore,
        'resume_strength': (analysisResult['experience_score'] as num? ?? 85).toInt(),
        'skill_completeness': (analysisResult['skills_score'] as num? ?? 80).toInt(),
      });

      // 5. Update user_usage_limits count
      final limitsRes = await _supabase
          .from('user_usage_limits')
          .select('ats_scans_used_today')
          .eq('user_id', user.id)
          .maybeSingle();

      final currentUsed = limitsRes?['ats_scans_used_today'] as int? ?? 0;
      await _supabase
          .from('user_usage_limits')
          .update({'ats_scans_used_today': currentUsed + 1})
          .eq('user_id', user.id);
    } catch (e) {
      // Log db insert warning if schema RLS blocks
    }

    return analysisResult;
  }
}
