# Theme Preset Engine Specification

## The Architecture
The application features a dynamic Theme Preset Engine (`theme_presets.dart`) that completely decouples color logic from UI components.

### Contract
`AppThemePreset` is the interface defining every semantic color needed by the app (primary, secondary, text, backgrounds).

### Supported Themes
1. **`AppleHeadspaceTheme` (Default)**: Walnut Brown, Terracotta, Amber, Sage.
2. **`PurplePremiumTheme`**: Royal Purple, Amethyst, Lavender.
3. **`EmeraldTheme`**: Deep Emerald, Mint, Jade.
4. **`RoyalGoldTheme`**: Onyx Black, Champagne Gold.

### How It Works
The design tokens (`app_colors.dart`, `app_gradients.dart`, `app_shadows.dart`) read their values dynamically from `AppTheme.current`. 

To change the theme of the entire application, a developer (or eventually a state provider) simply updates the singleton instance:
```dart
AppTheme.current = PurplePremiumTheme();
```
Because no screen or component hardcodes a color, this single line instantly reskins the entire application without any further code changes.
