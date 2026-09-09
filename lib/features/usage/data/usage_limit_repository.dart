import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/supabase_service.dart';

final usageLimitRepositoryProvider = Provider<UsageLimitRepository>((ref) {
  return UsageLimitRepository(SupabaseService.client);
});

class UsageLimitRepository {
  final SupabaseClient _client;

  UsageLimitRepository(this._client);

  Future<Map<String, dynamic>> getUserLimits(String userId) async {
    final response = await _client
        .from('user_usage_limits')
        .select()
        .eq('user_id', userId)
        .single();
    
    // Check if limits need to be reset (e.g. new day)
    // In production, this might be handled via a daily cron job or Edge Function
    // For now, return the current data
    return response;
  }

  Future<bool> canPerformAtsScan(String userId, String planType) async {
    if (planType != 'free') return true;

    final limits = await getUserLimits(userId);
    final usedToday = limits['ats_scans_used_today'] as int? ?? 0;
    
    // Free limit is 2 per day
    return usedToday < 2;
  }

  Future<void> incrementAtsScan(String userId) async {
    final limits = await getUserLimits(userId);
    final usedToday = limits['ats_scans_used_today'] as int? ?? 0;
    
    await _client
        .from('user_usage_limits')
        .update({'ats_scans_used_today': usedToday + 1})
        .eq('user_id', userId);
  }
}
