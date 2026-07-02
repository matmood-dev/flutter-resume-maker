import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

void main() {
  runApp(const ProviderScope(child: ResumeAIApp()));
}

class ResumeAIApp extends StatelessWidget {
  const ResumeAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ResumeAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
