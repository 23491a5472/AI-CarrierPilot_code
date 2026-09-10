import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/env_config.dart';
import 'services/supabase_service.dart';
import 'core/services/ad_service.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Completely hide system bottom navigation bar using Immersive Sticky mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Initialize Environment variables (.env)
  await EnvConfig.init();
  
  // Initialize Supabase Client
  await SupabaseService.init();

  // Initialize Google Mobile Ads SDK
  await AdService.init();

  runApp(
    const ProviderScope(
      child: CareerPilotApp(),
    ),
  );
}

class CareerPilotApp extends ConsumerWidget {
  const CareerPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'CareerPilot AI',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
