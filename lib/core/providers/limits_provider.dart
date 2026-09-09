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
        .single();
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
        .from('usage_limits')
        .select()
        .eq('user_id', user.id)
        .single();
    return response;
  } catch (e) {
    return null;
  }
});

// Helper provider to check if user has premium access
final isPremiumProvider = Provider<bool>((ref) {
  final subStatus = ref.watch(subscriptionProvider).value;
  if (subStatus == null) return false;
  
  final status = subStatus['status'] as String?;
  return status == 'active' || status == 'trialing';
});
