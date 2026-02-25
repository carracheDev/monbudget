import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/api_client.dart';
import 'package:monbudget/data/repositories/auth_repository.dart';
import 'package:monbudget/data/repositories/budget_repository.dart';
import 'package:monbudget/data/repositories/categorie_repository.dart';
import 'package:monbudget/data/repositories/compte_repository.dart';
import 'package:monbudget/data/repositories/epargne_repository.dart';
import 'package:monbudget/data/repositories/notification_repository.dart';
import 'package:monbudget/data/repositories/parametres_repository.dart';
import 'package:monbudget/data/repositories/portefeuille_repository.dart';
import 'package:monbudget/data/repositories/rapport_repository.dart';
import 'package:monbudget/data/repositories/transaction_repository.dart';
import 'package:monbudget/data/services/auth_service.dart';
import 'package:monbudget/data/services/budget_service.dart';
import 'package:monbudget/data/services/categorie_service.dart';
import 'package:monbudget/data/services/compte_service.dart';
import 'package:monbudget/data/services/epargne_service.dart';
import 'package:monbudget/data/services/notification_service.dart';
import 'package:monbudget/data/services/parametres_service.dart';
import 'package:monbudget/data/services/portefeuille_service.dart';
import 'package:monbudget/data/services/rapport_service.dart';
import 'package:monbudget/data/services/transaction_service.dart';

// Provider qui crée ApiClient une seul fois

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// AuthRepository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final authService = AuthService(apiClient);
  return AuthRepository(authService);
});

// BudgetRepository provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final budgetService = BudgetService(apiClient);
  return BudgetRepository(budgetService);
});

// CategorieRepository Provider

final categorieRepositoryProvider = Provider<CategorieRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final categorieService = CategorieService(apiClient);
  return CategorieRepository(categorieService);
});

// CompteRepository Provider
final compteRepositoryProvider = Provider<CompteRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final compteService = CompteService(apiClient);
  return CompteRepository(compteService);
});

// EpargneRepository Provider
final epargneRepositoryProvider = Provider<EpargneRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final epargneService = EpargneService(apiClient);
  return EpargneRepository(epargneService);
});

// NotificationRepository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final notificationService = NotificationService(apiClient);
  return NotificationRepository(notificationService);
});

//ParametreRepository Provider
final parametreRepositoryProvider = Provider<ParametresRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final parametresService = ParametresService(apiClient);
  return ParametresRepository(parametresService);
});

//PortefeuilleRepository Provider
final portefeuilleRepositoryProvider = Provider<PortefeuilleRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final portefeuilleService = PortefeuilleService(apiClient);
  return PortefeuilleRepository(portefeuilleService);
});

// RapportRepository Provider
final rapportRepositoryProvider = Provider<RapportRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final rapportService = RapportService(apiClient);
  return RapportRepository(rapportService);
});

// TransactionRepository Provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final transactionService = TransactionService(apiClient);
  return TransactionRepository(transactionService);
});
