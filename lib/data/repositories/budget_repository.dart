import 'package:dio/dio.dart';
import 'package:monbudget/data/models/budget_model.dart';
import 'package:monbudget/data/services/budget_service.dart';

class BudgetRepository {
  final BudgetService _budgetService;
  BudgetRepository(this._budgetService);

  Future<BudgetModel> createBudgets({
    required double montantLimite,
    required BudgetPeriode periode,
  }) async {
    try {
      return await _budgetService.createBudgets(
        montantLimite: montantLimite,
        periode: periode,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de creaction de budget',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<List<BudgetModel>> getBudgets() async {
    try {
      return await _budgetService.getBudgets();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur lors de recuperation du budget',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<void> deleteBudgets(String budgetId) async {
    try {
      await _budgetService.deleteBudgets(budgetId);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de supppresion de mudgets',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<BudgetModel> updateBudgets({
    required String budgetId,
    double? montantLimite,
  }) async {
    try {
      return await _budgetService.updateBudgets(
        budgetId: budgetId,
        montantLimite: montantLimite,
        );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de modification');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }
}
