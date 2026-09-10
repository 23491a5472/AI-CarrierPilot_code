import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_presets.dart';

/// Notifier controlling current theme preset (Dark Mode vs Light Mode)
class ThemeNotifier extends Notifier<AppThemePreset> {
  @override
  AppThemePreset build() {
    AppTheme.current = TechnicalSlateDarkTheme();
    return TechnicalSlateDarkTheme();
  }

  void toggleTheme(bool isDark) {
    state = isDark ? TechnicalSlateDarkTheme() : QuartzMintLightTheme();
    AppTheme.current = state;
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemePreset>(ThemeNotifier.new);
