import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/auth_provider.dart';

final skillGapRepositoryProvider = Provider((ref) {
  return SkillGapRepository(ref.watch(supabaseClientProvider));
});

class SkillGapRepository {
  final SupabaseClient _supabase;

  SkillGapRepository(this._supabase);

  Future<Map<String, dynamic>> generateSkillGapReport(String resumeText, String jobDescription) async {
    final response = await _supabase.functions.invoke(
      'generate-skill-gap-report',
      body: {
        'resume_text': resumeText,
        'job_description': jobDescription,
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to generate skill gap report (status ${response.status})');
    }

    return response.data as Map<String, dynamic>;
  }
}
