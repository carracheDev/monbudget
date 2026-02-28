import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/app_router.dart';
import './core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MonBudgetApp()));
}

class MonBudgetApp extends StatelessWidget {
  const MonBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // automatique selon téléphone
      title: 'MonBudget',
      routerConfig:appRouter,
    );
  }
}


