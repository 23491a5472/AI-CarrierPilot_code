import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/env_config.dart';
import 'services/supabase_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Environment variables (.env)
  await EnvConfig.init();
  
  // Initialize Supabase Client
  await SupabaseService.init();

  runApp(
    const ProviderScope(
      child: CareerPilotApp(),
    ),
  );
}

class CareerPilotApp extends StatelessWidget {
  const CareerPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareerPilot AI',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const PlaceholderScreen(),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'CareerPilot AI',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Flutter + Supabase Client Initialized!'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Future Routing Navigation
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
