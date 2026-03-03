import 'package:monbudget/core/config/api_client.dart';

import '../models/transaction_model.dart';

class TransactionService {
  final ApiClient _apiClient;

  TransactionService(this._apiClient);

  Future<List<TransactionModel>> getTransactions() async {
    final response = await _apiClient.dio.get('/transactions');

    // response.data est une liste → on convertit chaque élément
    return (response.data as List)
        .map((item) => TransactionModel.fromJson(item))
        .toList();
  }

  //Creaction de transaction

  Future<TransactionModel> createTransaction({
    required double montant,
    required String type,
    required String categorieId,
    String? description,
  }) async {
    final response = await _apiClient.dio.post(
      '/transactions',
      data: {
        'montant': montant,
        'type': type,
        'categorieId': categorieId,
        'description': description,
      },
    );
    return TransactionModel.fromJson(response.data);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _apiClient.dio.delete('/transactions/$transactionId');
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _apiClient.dio.get('/transactions/stats/mois');
    return response.data;
  }
}
