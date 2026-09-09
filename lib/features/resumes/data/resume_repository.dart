import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/supabase_service.dart';
import 'storage_repository.dart';

final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  return ResumeRepository(
    SupabaseService.client,
    ref.read(storageRepositoryProvider),
  );
});

class ResumeRepository {
  final SupabaseClient _client;
  final StorageRepository _storageRepo;

  ResumeRepository(this._client, this._storageRepo);

  Future<List<Map<String, dynamic>>> getActiveResumes(String userId) async {
    return await _client
        .from('resumes')
        .select()
        .eq('user_id', userId)
        .eq('is_deleted', false)
        .order('upload_date', ascending: false);
  }

  Future<void> uploadAndCreateResume(String userId, File pdfFile) async {
    // Basic limit check on client side. Also enforced in Edge Functions later.
    final countResponse = await _client
        .from('resumes')
        .select('id')
        .eq('user_id', userId)
        .eq('is_deleted', false)
        .count(CountOption.exact);
        
    final count = countResponse.count ?? 0;
    final isPremium = await _checkIfPremium(userId);
    
    if (!isPremium && count >= 2) {
      throw Exception('Free users can only store up to 2 resumes.');
    }

    // 1. Create a DB record placeholder to get an ID
    final fileName = pdfFile.path.split('/').last;
    final fileSize = await pdfFile.length();
    
    final resumeInsert = await _client.from('resumes').insert({
      'user_id': userId,
      'original_file_name': fileName,
      'storage_path': 'temp', // will be updated
      'file_size': fileSize,
    }).select().single();
    
    final resumeId = resumeInsert['id'];

    // 2. Upload to Storage
    final storagePath = await _storageRepo.uploadResume(userId, resumeId, pdfFile);

    // 3. Update DB record with correct path
    await _client.from('resumes').update({
      'storage_path': storagePath,
    }).eq('id', resumeId);
  }
  
  Future<void> softDeleteResume(String resumeId) async {
    await _client.from('resumes').update({
      'is_deleted': true,
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', resumeId);
  }

  Future<bool> _checkIfPremium(String userId) async {
    final sub = await _client
        .from('subscription_status')
        .select('plan_type')
        .eq('user_id', userId)
        .single();
    return sub['plan_type'] != 'free';
  }
}
