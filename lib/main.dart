import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/app_router.dart';
import 'package:monbudget/features/parametres/theme_screen.dart';
import './core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MonBudgetApp()));
}

class MonBudgetApp extends ConsumerWidget {
  const MonBudgetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Utilise le provider pour le thème
      title: 'MonBudget',
      routerConfig: appRouter,
    );
  }
}
