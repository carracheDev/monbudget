import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/features/auth/splash_screen.dart';
import './core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MonBudgetApp()));
}

final compteurProvider = StateProvider<int>((ref) => 0);

class MonBudgetApp extends StatelessWidget {
  const MonBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // automatique selon téléphone
      title: 'MonBudget',
      home:const SplashScreen(),
    );
  }
}


