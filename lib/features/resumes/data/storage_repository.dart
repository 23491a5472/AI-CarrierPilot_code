import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/supabase_service.dart';

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(SupabaseService.client);
});

class StorageRepository {
  final SupabaseClient _client;

  StorageRepository(this._client);

  Future<String> uploadResume(String userId, String resumeId, File file) async {
    final fileName = file.path.split('/').last;
    final path = '$userId/$resumeId/$fileName';

    await _client.storage.from('resumes').upload(
      path, 
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );

    return path;
  }

  Future<String> getResumeUrl(String path) async {
    return _client.storage.from('resumes').getPublicUrl(path);
  }

  Future<void> deleteResumeFile(String path) async {
    await _client.storage.from('resumes').remove([path]);
  }
}
