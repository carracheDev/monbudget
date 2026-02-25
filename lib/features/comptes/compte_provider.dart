import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/data/models/compte_model.dart';
import 'package:monbudget/data/repositories/compte_repository.dart';

class CompteState {
  final List<CompteModel> comptes;
  final bool isLoading;
  final String? error;

  CompteState({this.comptes = const [], this.error, this.isLoading = false});

  CompteState copyWith({
    List<CompteModel>? comptes,
    bool? isLoading,
    String? error,
  }) {
    return CompteState(
      comptes: comptes ?? this.comptes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ================= NOTIFIER =================
class CompteNotifier extends StateNotifier<CompteState> {
  final CompteRepository _compteRepository;
  CompteNotifier(this._compteRepository) : super(CompteState());

  Future<void> getCompte() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _compteRepository.getCompte();
      state = state.copyWith(isLoading: false, comptes: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createCompte({
    required String nom,
    required CompteType type,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _compteRepository.createCompte(nom: nom, type: type);
      await getCompte();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteCompte(String compteId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _compteRepository.deleteCompte(compteId);
      await getCompte();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateCompte({required String compteId, String? nom}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _compteRepository.updateCompte(compteId: compteId, nom: nom);
      await getCompte();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ================= PROVIDER =================

final compteProvider = StateNotifierProvider<CompteNotifier, CompteState>((
  ref,
) {
  final compteRepository = ref.read(compteRepositoryProvider);
  return CompteNotifier(compteRepository);
});
