# Design System Specification

## The "Tokenized" Approach
The application uses a strict tokenized design system located in `lib/core/theme/`.

**CRITICAL RULE: No hardcoded design values are allowed inside UI screen files.**

### Design Tokens
1. **Colors (`app_colors.dart`)**: Exposes dynamic getters mapping to semantic names (e.g., `AppColors.primary`, `AppColors.success`).
2. **Gradients (`app_gradients.dart`)**: Defines standard linear and radial gradients (e.g., `heroGradient`, `blobCoral`).
3. **Typography (`app_text_styles.dart`)**: Defines the text hierarchy (`h1`, `h2`, `bodyMedium`, `caption`).
4. **Spacing (`app_spacing.dart`)**: Defines standard padding/margin increments (e.g., `AppSpacing.sm = 8.0`, `AppSpacing.xl = 32.0`).
5. **Radius (`app_radius.dart`)**: Defines standardized border radii for inputs, cards, and buttons.
6. **Shadows (`app_shadows.dart`)**: Defines complex drop shadows for glassmorphism and floating elements.

All tokens react to the active preset defined in the `Theme Preset Engine`.
