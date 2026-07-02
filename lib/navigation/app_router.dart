import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/ai/ai_assistant_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/cover_letter/cover_letter_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/resume/resume_builder_screen.dart';
import '../features/resume/resumes_screen.dart';
import '../features/resume/template_selection_screen.dart';
import '../features/scanner/scanner_screen.dart';
import '../features/templates/templates_screen.dart';
import '../models/resume_model.dart';
import 'main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    if (isLoggedIn && isAuthRoute) {
      return '/home/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/home/resumes',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ResumesScreen(),
          ),
        ),
        GoRoute(
          path: '/home/ai',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AiAssistantScreen(),
          ),
        ),
        GoRoute(
          path: '/home/templates',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TemplatesScreen(),
          ),
        ),
        GoRoute(
          path: '/home/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/resume/create',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final resume = state.extra as ResumeModel?;
        return ResumeBuilderScreen(existingResume: resume);
      },
    ),
    GoRoute(
      path: '/resume/template-selection',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final resume = state.extra;
        return TemplateSelectionScreen(resume: resume as dynamic);
      },
    ),
    GoRoute(
      path: '/scanner',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ScannerScreen(),
    ),
    GoRoute(
      path: '/cover-letter/create',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CoverLetterScreen(),
    ),
  ],
);
