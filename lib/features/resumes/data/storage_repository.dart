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
    final rawName = file.path.split('/').last;
    final sanitizedName = rawName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path = '$userId/$sanitizedName';

    final bytes = await file.readAsBytes();

    String contentType = 'application/octet-stream';
    final ext = sanitizedName.split('.').last.toLowerCase();
    if (ext == 'pdf') {
      contentType = 'application/pdf';
    } else if (ext == 'docx') {
      contentType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    } else if (ext == 'doc') {
      contentType = 'application/msword';
    } else if (ext == 'txt') {
      contentType = 'text/plain';
    }

    try {
      await _client.storage.from('resumes').uploadBinary(
        path, 
        bytes,
        fileOptions: FileOptions(cacheControl: '3600', upsert: true, contentType: contentType),
      );
      return path;
    } on StorageException catch (e) {
      final msg = e.message.toLowerCase();
      if (e.statusCode == '404' || msg.contains('not found') || msg.contains('bucket')) {
        try {
          await _client.storage.createBucket('resumes', const BucketOptions(public: true));
          await _client.storage.from('resumes').uploadBinary(
            path, 
            bytes,
            fileOptions: FileOptions(cacheControl: '3600', upsert: true, contentType: contentType),
          );
          return path;
        } catch (_) {}
      }
      rethrow;
    } catch (e) {
      throw Exception('Failed to upload resume file: $e');
    }
  }

  Future<String> getResumeUrl(String path) async {
    try {
      return _client.storage.from('resumes').getPublicUrl(path);
    } catch (_) {
      return path;
    }
  }

  Future<void> deleteResumeFile(String path) async {
    try {
      await _client.storage.from('resumes').remove([path]);
    } catch (_) {
      // Ignore if file doesn't exist
    }
  }
}
