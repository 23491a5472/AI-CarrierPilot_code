# Flutter Architecture Specification

## Architectural Pattern
The application uses **Clean Architecture** combined with **Feature-First folder structuring**.

### Directory Structure
```
lib/
├── core/
│   ├── providers/        # Global Riverpod providers (Auth, Profile, Theme)
│   ├── theme/            # Global Design Tokens & Theme Engine
│   └── network/          # Supabase client initialization
├── features/
│   ├── analyze/
│   │   ├── data/         # Repositories (calling Edge Functions)
│   │   ├── domain/       # Entities and Models
│   │   └── presentation/ # UI Screens and local widgets
│   ├── auth/
│   ├── dashboard/
│   └── ...
├── shared/
│   ├── widgets/          # Global reusable UI components
│   └── utils/            # Helper functions
```

## State Management
**Riverpod** is the exclusive state management solution.
- `ConsumerWidget` and `ConsumerStatefulWidget` are used for all connected UI.
- `AsyncValue` is used to gracefully handle Loading, Error, and Data states.

## Backend Communication
- All database CRUD operations go through Supabase PostgREST.
- All Gemini AI operations go through **Supabase Edge Functions**. The Gemini API key is *never* exposed to the Flutter client.
