import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/auth_provider.dart';

final analyzeRepositoryProvider = Provider((ref) {
  return AnalyzeRepository(ref.watch(supabaseClientProvider));
});

class AnalyzeRepository {
  final SupabaseClient _supabase;

  AnalyzeRepository(this._supabase);

  Future<String> uploadResume(File file) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final path = '$userId/$fileName';

    await _supabase.storage.from('resumes').upload(path, file);
    return path;
  }

  Future<Map<String, dynamic>> analyzeResume(String resumePath, String jobDescription) async {
    // Invoke the Supabase Edge Function 'analyze-resume'
    final response = await _supabase.functions.invoke(
      'analyze-resume',
      body: {
        'resume_path': resumePath,
        'job_description': jobDescription,
      },
    );

    if (response.status != 200) {
      throw Exception('Analysis failed: ${response.error}');
    }

    return response.data as Map<String, dynamic>;
  }
}
