import 'package:go_router/go_router.dart';
import 'package:monbudget/features/auth/login_screen.dart';
import 'package:monbudget/features/auth/onboarding_screen.dart';
import 'package:monbudget/features/auth/register_screen.dart';
import 'package:monbudget/features/auth/splash_screen.dart';
import 'package:monbudget/features/epargne/epargne_screnn.dart';
import 'package:monbudget/features/notifications/notifications_screen.dart';
import 'package:monbudget/features/parametres/parametres_screen.dart';
import 'package:monbudget/features/parametres/modifier_profil_screen.dart';
import 'package:monbudget/features/parametres/notifications_settings_screen.dart';
import 'package:monbudget/features/parametres/theme_screen.dart';
import 'package:monbudget/features/parametres/language_screen.dart';
import 'package:monbudget/features/parametres/security_screen.dart';
import 'package:monbudget/features/parametres/devise_screen.dart';
import 'package:monbudget/features/parametres/about_screen.dart';
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
    GoRoute(
      path: '/parametres',
      builder: (context, state) => const ParametresScreen(),
    ),
    GoRoute(
      path: '/profile_edit',
      builder: (context, state) => const ModifierProfilScreen(),
    ),
    GoRoute(
      path: '/notifications_settings',
      builder: (context, state) => const NotificationsSettingsScreen(),
    ),
    GoRoute(path: '/theme', builder: (context, state) => const ThemeScreen()),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: '/security',
      builder: (context, state) => const SecurityScreen(),
    ),
    GoRoute(path: '/devise', builder: (context, state) => const DeviseScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
  ],
); // Dans dashboard, transactions, etc.
