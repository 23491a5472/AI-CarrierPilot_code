import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/env_config.dart';

class SupabaseService {
  static Future<void> init() async {
    if (EnvConfig.supabaseUrl.isEmpty || EnvConfig.supabaseAnonKey.isEmpty) {
      throw Exception('Supabase URL or Anon Key is missing in .env file.');
    }
    
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
