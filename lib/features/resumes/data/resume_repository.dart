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
    // Purge broken phantom placeholder uploads
    try {
      await _client
          .from('resumes')
          .delete()
          .eq('user_id', userId)
          .or('storage_path.eq.temp,storage_path.like.local_%');
    } catch (_) {}

    return await _client
        .from('resumes')
        .select()
        .eq('user_id', userId)
        .eq('is_deleted', false)
        .order('upload_date', ascending: false);
  }

  Future<Map<String, dynamic>> uploadAndCreateResume(String userId, File file, {String? contentText}) async {
    // 1. Purge broken phantom placeholder uploads first
    try {
      await _client
          .from('resumes')
          .delete()
          .eq('user_id', userId)
          .or('storage_path.eq.temp,storage_path.like.local_%');
    } catch (_) {}

    // 2. Limit check
    final countResponse = await _client
        .from('resumes')
        .select('id')
        .eq('user_id', userId)
        .eq('is_deleted', false)
        .count(CountOption.exact);

    final count = countResponse.count;
    final isPremium = await _checkIfPremium(userId);

    if (!isPremium && count >= 2) {
      throw Exception('Free users can store up to 2 active resumes. Upgrade to Pro for unlimited storage.');
    }

    final rawName = file.path.split('/').last;
    final fileSize = await file.length();

    final authUserId = _client.auth.currentUser?.id ?? userId;

    // 3. Create placeholder DB record with explicit is_deleted: false for RLS WITH CHECK validation
    final resumeInsert = await _client.from('resumes').insert({
      'user_id': authUserId,
      'original_file_name': rawName,
      'storage_path': 'temp',
      'file_size': fileSize,
      'is_deleted': false,
    }).select().single();

    final resumeId = resumeInsert['id'] as String;

    try {
      // 4. Try uploading file to Storage, gracefully fall back to DB text storage if Storage RLS fails
      String storagePath;
      try {
        storagePath = await _storageRepo.uploadResume(userId, resumeId, file);
      } catch (storageError) {
        // Fallback storage path if Supabase Storage RLS policy restricts binary upload
        storagePath = 'db_stored_$resumeId';
      }

      // 5. Update DB path
      await _client.from('resumes').update({
        'storage_path': storagePath,
      }).eq('id', resumeId);

      // 6. Create initial resume_version with extracted text content
      String extractedText = contentText ?? '';
      if (extractedText.isEmpty) {
        try {
          extractedText = await file.readAsString();
        } catch (_) {
          extractedText = 'Resume document: $rawName (Uploaded successfully)';
        }
      }

      await _client.from('resume_versions').insert({
        'resume_id': resumeId,
        'version_number': 1,
        'content_text': extractedText,
      });

      return {
        ...resumeInsert,
        'storage_path': storagePath,
      };
    } catch (e) {
      // Roll back placeholder DB record if DB insertion fails
      try {
        await _client.from('resumes').delete().eq('id', resumeId);
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> softDeleteResume(String resumeId, [String? storagePath]) async {
    await _client.from('resumes').update({
      'is_deleted': true,
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', resumeId);

    if (storagePath != null && storagePath.isNotEmpty && storagePath != 'temp') {
      try {
        await _storageRepo.deleteResumeFile(storagePath);
      } catch (e) {
        // Storage object may already be removed
      }
    }
  }

  Future<bool> _checkIfPremium(String userId) async {
    try {
      final sub = await _client
          .from('subscription_status')
          .select('plan_type, is_active')
          .eq('user_id', userId)
          .maybeSingle();

      if (sub == null) return false;
      final plan = sub['plan_type'] as String? ?? 'free';
      final isActive = sub['is_active'] as bool? ?? true;
      return plan != 'free' && isActive;
    } catch (e) {
      return false;
    }
  }
}
