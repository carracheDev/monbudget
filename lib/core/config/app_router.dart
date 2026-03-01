import 'package:go_router/go_router.dart';
import 'package:monbudget/features/auth/login_screen.dart';
import 'package:monbudget/features/auth/onboarding_screen.dart';
import 'package:monbudget/features/auth/register_screen.dart';
import 'package:monbudget/features/auth/splash_screen.dart';
import 'package:monbudget/features/epargne/epargne_screnn.dart';
import 'package:monbudget/features/notifications/notifications_screen.dart';
import 'package:monbudget/features/portefeuille/portefeuille_screen.dart';
import 'package:monbudget/features/rapports/rapport_screen.dart';
import 'package:monbudget/features/transactions/transactions_screen.dart';
import 'package:monbudget/shared/components/main_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/portefeuille',
      builder: (context, state) => const PortefeuilleScreen(),
    ),
    GoRoute(
      path: '/transactions',

      builder: (context, state) => const TransactionsScreen(),
    ),
    GoRoute(
      path: '/epargne',
      builder: (context, state) => const EpargneScreen(),
    ),
    GoRoute(
      path: '/rapport',
      builder: (context, state) => const RapportsScreen(),
    ),
  ],
); // Dans dashboard, transactions, etc.
