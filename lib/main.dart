import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/app_router.dart';
import 'package:monbudget/core/services/firebase_messaging_service.dart';
import './core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅
  await FirebaseMessagingService.init(); // ✅
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
      themeMode: ThemeMode.system,
      title: 'MonBudget',
      routerConfig: appRouter,
    );
  }
}