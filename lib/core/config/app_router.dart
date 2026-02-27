
import 'package:go_router/go_router.dart';
import 'package:monbudget/features/auth/login_screen.dart';
import 'package:monbudget/features/auth/onboarding_screen.dart';
import 'package:monbudget/features/auth/register_screen.dart';
import 'package:monbudget/features/auth/splash_screen.dart';
import 'package:monbudget/shared/components/main_screen.dart';

final appRouter =  GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder:(context, state) => const SplashScreen(),
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
      path:'/register',
      builder: (context, state) => const RegisterScreen(), 
      ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const MainScreen(),
      )
  ]
  );