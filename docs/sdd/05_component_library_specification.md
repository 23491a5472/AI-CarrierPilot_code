# Component Library Specification

The UI is built exclusively by assembling blocks from `lib/shared/widgets/`.

## Core Components
- **`AppScaffold`**: The base wrapper for all screens. Automatically applies background colors and floating radial gradient "blobs" for layered depth.
- **`GlassCard`**: The fundamental UI container. It automatically applies `BackdropFilter` for frosted glass blur, translucent borders, and soft shadows.
- **`GradientButton`**: The primary CTA button using standard gradients.
- **`PremiumTextField`**: Styled input fields for forms and authentication.
- **`ScoreRing`**: An animated circular progress indicator for displaying ATS scores and career health metrics.
- **`SkillChip`**: Colored pills used to represent matched/missing skills.
- **`SectionHeader`**: A standardized layout for section titles and subtitles.
- **`EmptyStateCard`**: A beautifully styled zero-state container.
- **`UsageLimitBadge`**: A pill displaying current usage against Free Tier limits.
- **`PremiumBottomNav`**: The main frosted-glass persistent navigation bar.
- **`NativeAdCard` / `BannerAdSlot`**: Premium placeholders for integrating monetization seamlessly into the design.

**Rule:** Screens must *only* use these shared components to maintain global consistency. Custom, one-off UI widgets inside screens are strictly prohibited unless they are completely unique to that single screen.
