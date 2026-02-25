import 'package:dio/dio.dart';
import 'package:monbudget/data/models/transaction_model.dart';
import 'package:monbudget/data/services/transaction_service.dart';

class TransactionRepository {
  final TransactionService _transactionService;
  TransactionRepository(this._transactionService);

  Future<List<TransactionModel>> getTransactions() async {
    try {
      return await _transactionService.getTransactions();
    } on DioException catch (e) {
      throw (e.response?.data['message'] ?? 'Erreur de transactions');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<TransactionModel> createTransaction({
    required double montant,
    required TransactionType type,
    required String categorieId,
  }) async {
    try {
      return await _transactionService.createTransaction(
        montant: montant,
        type: type.name,
        categorieId: categorieId,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de transactions');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      return await _transactionService.deleteTransaction(transactionId);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur lors de la suppression ',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      return await _transactionService.getStats();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du state');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }
}
