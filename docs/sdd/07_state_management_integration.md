# State Management & Integration Specification

## Riverpod Providers
State management is handled via Riverpod. The primary domains are:

### Core Providers
- `authProvider`: Manages Supabase Auth state (loading, authenticated, unauthenticated).
- `profileProvider`: Fetches the `profiles` table data and caching `career_health_snapshots`.
- `limitsProvider`: Fetches `usage_limits` and enforces tier restrictions.
- `subscriptionProvider`: Tracks if the user is Free or Premium.

### Feature Repositories
Repositories handle API calls to Supabase PostgREST and Edge Functions:
- `analyzeRepository`: Uploads PDF to `resumes` bucket -> calls `analyze-resume` Edge Function -> stores JSON in `saved_jobs`/`career_health_snapshots`.
- `coverLetterRepository`: Calls `generate-cover-letter` Edge Function.
- `skillGapRepository`: Calls `generate-skill-gap-report` Edge Function.

## UI Integration Rules
1. **Ref.watch()**: Screens must use `ref.watch()` to read state reactively.
2. **AsyncValue Handling**: Every network call must be handled with `.when(data: ..., loading: ..., error: ...)`.
3. **Loading States**: The UI must not break layout during loading. Use embedded `CircularProgressIndicator` inside `GlassCard` containers.
4. **Usage Limits**: Actions (like uploading a resume) must check the `limitsProvider` before executing. If limits are exceeded, present the `PremiumScreen`.

## Security
- **No Gemini Keys in Client**: The Flutter client only communicates with Supabase. It uses the Supabase Auth token to call Edge Functions.
- **Edge Function Secrets**: The Gemini API key lives *only* in the Supabase Edge Function Secrets manager.
