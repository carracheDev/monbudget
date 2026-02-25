import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/data/models/epargne_model.dart';
import 'package:monbudget/data/repositories/epargne_repository.dart';

class EpargneState {
  final List<EpargneModel> epargne;
  final bool isLoading;
  final String? error;

  EpargneState({this.epargne = const [], this.error, this.isLoading = false});

  EpargneState copyWith({
    List<EpargneModel>? epargne,
    bool? isLoading,
    String? error,
  }) {
    return EpargneState(
      epargne: epargne ?? this.epargne,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ================= NOTIFIER =================
class EpargneNotifier extends StateNotifier<EpargneState> {
  final EpargneRepository _epargneRepository;
  EpargneNotifier(this._epargneRepository) : super(EpargneState());

  Future<void> getObjectifs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _epargneRepository.getObjectifs();
      state = state.copyWith(isLoading: false, epargne: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createObjectif({
    required String nom,
    required String icone,
    required double montantCible,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _epargneRepository.createObjectif(
        nom: nom,
        icone: icone,
        montantCible: montantCible,
      );
      await getObjectifs();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteObjectif(String epargneId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _epargneRepository.deleteObjectif(epargneId);
      await getObjectifs();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> ajouterContribution({
    required String epargneId,
    required double montant,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _epargneRepository.ajouterContribution(
        epargneId: epargneId,
        montant: montant,
      );
      await getObjectifs();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final epargneProvider = StateNotifierProvider<EpargneNotifier, EpargneState>((
  ref,
) {
  final epargneRepository = ref.read(epargneRepositoryProvider);
  return EpargneNotifier(epargneRepository);
});
