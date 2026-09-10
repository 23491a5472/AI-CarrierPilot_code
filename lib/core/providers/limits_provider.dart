import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

// Subscription Status Provider
final subscriptionProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final supabase = ref.watch(supabaseClientProvider);
  try {
    final response = await supabase
        .from('subscription_status')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    return response;
  } catch (e) {
    return null;
  }
});

// Usage Limits Provider
final usageLimitsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final supabase = ref.watch(supabaseClientProvider);
  try {
    final response = await supabase
        .from('user_usage_limits')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (response == null) {
      // Create initial limits record if not exists
      final newLimits = {
        'user_id': user.id,
        'ats_scans_used_today': 0,
        'cover_letters_used_today': 0,
        'resume_improvements_used_today': 0,
        'last_reset_date': DateTime.now().toIso8601String().split('T')[0],
      };
      await supabase.from('user_usage_limits').upsert(newLimits);
      return newLimits;
    }

    // Check if daily reset is required
    final lastResetStr = response['last_reset_date'] as String?;
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    if (lastResetStr != todayStr) {
      final resetData = {
        'user_id': user.id,
        'ats_scans_used_today': 0,
        'cover_letters_used_today': 0,
        'resume_improvements_used_today': 0,
        'last_reset_date': todayStr,
      };
      await supabase.from('user_usage_limits').update(resetData).eq('user_id', user.id);
      return {...response, ...resetData};
    }

    return response;
  } catch (e) {
    return null;
  }
});

// Helper provider to check if user has premium access
final isPremiumProvider = Provider<bool>((ref) {
  final subStatus = ref.watch(subscriptionProvider).value;
  if (subStatus == null) return false;

  final planType = subStatus['plan_type'] as String? ?? 'free';
  final isActive = subStatus['is_active'] as bool? ?? true;
  return planType != 'free' && isActive;
});
