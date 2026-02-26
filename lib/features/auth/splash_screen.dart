import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/core/constants/app_constants.dart';
import 'package:monbudget/core/constants/app_strings.dart';
import 'package:monbudget/core/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 5));

    // 1. Vérifier si onboarding déjà vu
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone =
        prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

    if (!onboardingDone) {
      // Prmiere fois => Onboarding
      if (mounted) {
        context.go('/onboarding');
      }
      return;
    }

    // 2. Vérifier si token JWT existe
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConstants.keyAccessToken);

    if (!mounted) return;
    if (token != null) {
      // Déja connecté => Dashboard
      context.go('/dashboard');
    } else {
      // Onboarding vu mais pas connecté => Login
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppStrings.appName, style: AppTextStyles.montantPrincipal),
            const SizedBox(height: 8),
            Text(AppStrings.appTagline, style: AppTextStyles.labelSecondaire),
            const SizedBox(height: 32),
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
