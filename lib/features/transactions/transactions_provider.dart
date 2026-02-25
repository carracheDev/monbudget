import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/data/models/transaction_model.dart';
import 'package:monbudget/data/repositories/transaction_repository.dart';

// ================= STATE =================
class TransactionsState {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;

  TransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ================= NOTIFIER =================
class TransactionsNotifier extends StateNotifier<TransactionsState> {
  final TransactionRepository _transactionRepository;

  TransactionsNotifier(this._transactionRepository)
      : super(TransactionsState());

  // GET TRANSACTIONS
  Future<void> getTransactions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _transactionRepository.getTransactions();
      state = state.copyWith(isLoading: false, transactions: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // CREATE TRANSACTION
  Future<void> createTransaction({
    required double montant,
    required TransactionType type,
    required String categorieId,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _transactionRepository.createTransaction(
        montant: montant,
        type: type,
        categorieId: categorieId,
      );
      // Recharger la liste après création
      await getTransactions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // DELETE TRANSACTION
  Future<void> deleteTransaction(String transactionId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _transactionRepository.deleteTransaction(transactionId);
      // Recharger la liste après suppression
      await getTransactions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ================= PROVIDER =================
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  final transactionRepository = ref.read(transactionRepositoryProvider);
  return TransactionsNotifier(transactionRepository);
});