import 'package:monbudget/core/config/api_client.dart';
import 'package:monbudget/data/models/budget_model.dart';

class BudgetService {
  final ApiClient _apiClient;

  BudgetService(this._apiClient);

  Future<BudgetModel> createBudgets({
    required double montantLimite,
    required BudgetPeriode periode,
    required String categorieId,
  }) async {
    final response = await _apiClient.dio.post(
      '/budgets',
      data: {
        'montantLimite': montantLimite,
        'periode': periode.name,
        'categorieId': categorieId,
      },
    );
    return BudgetModel.fromJson(response.data);
  }

  //Liste des budegts
  Future<List<BudgetModel>> getBudgets() async {
    final response = await _apiClient.dio.get('/budgets');
    return (response.data as List)
        .map((item) => BudgetModel.fromJson(item))
        .toList();
  }

  Future<void> deleteBudgets(String budgetId) async {
    await _apiClient.dio.delete('/budgets/$budgetId');
  }

  Future<BudgetModel> updateBudgets({
    required String budgetId,
    double? montantLimite,
  }) async {
    final response = await _apiClient.dio.patch(
      '/budgets/$budgetId',
      data: {'montantLimite': ?montantLimite},
    );
    return BudgetModel.fromJson(response.data);
  }
}
