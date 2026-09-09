import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String get admobAppIdAndroid => dotenv.env['ADMOB_APP_ID_ANDROID'] ?? '';
  static String get admobBannerId => dotenv.env['ADMOB_BANNER_ID'] ?? '';
  static String get admobNativeId => dotenv.env['ADMOB_NATIVE_ID'] ?? '';
  static String get admobInterstitialId => dotenv.env['ADMOB_INTERSTITIAL_ID'] ?? '';
  static String get admobRewardedId => dotenv.env['ADMOB_REWARDED_ID'] ?? '';
}
