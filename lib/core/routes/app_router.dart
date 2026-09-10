import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/analyze/presentation/screens/analyze_screen.dart';
import '../../features/analyze/presentation/screens/ats_result_screen.dart';
import '../../features/cover_letter/presentation/screens/cover_letter_screen.dart';
import '../../features/interview_prep/presentation/screens/interview_prep_screen.dart';
import '../../features/job_tracker/presentation/screens/job_tracker_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/career_targets_screen.dart';
import '../../features/profile/presentation/screens/usage_telemetry_screen.dart';
import '../../features/profile/presentation/screens/ai_persona_screen.dart';
import '../../features/profile/presentation/screens/account_settings_screen.dart';
import '../../features/resume_library/presentation/screens/resume_library_screen.dart';
import '../../features/skill_gap/presentation/screens/skill_gap_screen.dart';
import '../../features/premium/presentation/screens/premium_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/analyze',
      builder: (context, state) => const AnalyzeScreen(),
    ),
    GoRoute(
      path: '/ats-result',
      builder: (context, state) => AtsResultScreen(analysisData: state.extra as Map<String, dynamic>?),
    ),
    GoRoute(
      path: '/cover-letter',
      builder: (context, state) => const CoverLetterScreen(),
    ),
    GoRoute(
      path: '/interview-prep',
      builder: (context, state) => const InterviewPrepScreen(),
    ),
    GoRoute(
      path: '/job-tracker',
      builder: (context, state) => const JobTrackerScreen(),
    ),
    GoRoute(
      path: '/jobs',
      builder: (context, state) => const JobTrackerScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/career-targets',
      builder: (context, state) => const CareerTargetsScreen(),
    ),
    GoRoute(
      path: '/profile/usage-telemetry',
      builder: (context, state) => const UsageTelemetryScreen(),
    ),
    GoRoute(
      path: '/profile/ai-persona',
      builder: (context, state) => const AiPersonaScreen(),
    ),
    GoRoute(
      path: '/profile/account-settings',
      builder: (context, state) => const AccountSettingsScreen(),
    ),
    GoRoute(
      path: '/resume-library',
      builder: (context, state) => const ResumeLibraryScreen(),
    ),
    GoRoute(
      path: '/skill-gap',
      builder: (context, state) => const SkillGapScreen(),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
  ],
);
