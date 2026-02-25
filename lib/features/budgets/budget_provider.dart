import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/data/models/budget_model.dart';
import 'package:monbudget/data/repositories/budget_repository.dart';

// ================= STATE =================
class BudgetsState {
  final List<BudgetModel> budgets;
  final bool isLoading;
  final String? error;

  BudgetsState({
    this.budgets = const [],
    this.isLoading = false,
    this.error,
  });

  BudgetsState copyWith({
    List<BudgetModel>? budgets,
    bool? isLoading,
    String? error,
  }) {
    return BudgetsState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ================= NOTIFIER =================
class BudgetsNotifier extends StateNotifier<BudgetsState> {
  final BudgetRepository _budgetRepository;

  BudgetsNotifier(this._budgetRepository) : super(BudgetsState());

  Future<void> getBudgets() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _budgetRepository.getBudgets();
      state = state.copyWith(isLoading: false, budgets: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createBudget({
    required double montantLimite,
    required BudgetPeriode periode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _budgetRepository.createBudgets(
        montantLimite: montantLimite,
        periode: periode,
      );
      await getBudgets();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _budgetRepository.deleteBudgets(budgetId);
      await getBudgets();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ================= PROVIDER =================
final budgetsProvider =
    StateNotifierProvider<BudgetsNotifier, BudgetsState>((ref) {
  final budgetRepository = ref.read(budgetRepositoryProvider);
  return BudgetsNotifier(budgetRepository);
});
