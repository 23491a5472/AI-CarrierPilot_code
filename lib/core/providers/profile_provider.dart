import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

// Profile Data Provider
final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final supabase = ref.watch(supabaseClientProvider);
  
  try {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return response;
  } catch (e) {
    // If no profile exists, return null
    return null;
  }
});
