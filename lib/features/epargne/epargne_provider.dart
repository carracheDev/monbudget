import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/data/models/epargne_model.dart';
import 'package:monbudget/data/repositories/epargne_repository.dart';

class EpargneState {
  final List<EpargneModel> objectifs; // ✅ renommé epargne → objectifs
  final bool isLoading;
  final String? error;

  EpargneState({
    this.objectifs = const [],
    this.error,
    this.isLoading = false,
  });

  EpargneState copyWith({
    List<EpargneModel>? objectifs,
    bool? isLoading,
    String? error,
  }) {
    return EpargneState(
      objectifs: objectifs ?? this.objectifs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EpargneNotifier extends StateNotifier<EpargneState> {
  final EpargneRepository _epargneRepository;
  EpargneNotifier(this._epargneRepository) : super(EpargneState());

  Future<void> getObjectifs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _epargneRepository.getObjectifs();
      state = state.copyWith(isLoading: false, objectifs: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ✅ renommé + ajout dateEcheance
  Future<void> creerObjectif({
    required String nom,
    required String icone,
    required double montantCible,
    required DateTime dateEcheance,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _epargneRepository.createObjectif(
        nom: nom,
        icone: icone,
        montantCible: montantCible,
        dateEcheance: dateEcheance,
      );
      await getObjectifs();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteObjectif(String objectifId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _epargneRepository.deleteObjectif(objectifId);
      await getObjectifs();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ✅ renommé epargneId → objectifId
  Future<void> ajouterContribution({
    required String objectifId,
    required double montant,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _epargneRepository.ajouterContribution(
        epargneId: objectifId,
        montant: montant,
      );
      await getObjectifs();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ✅ nouvelle méthode archiver
  Future<void> archiverObjectif(String objectifId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _epargneRepository.deleteObjectif(objectifId);
      await getObjectifs();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final epargneProvider =
    StateNotifierProvider<EpargneNotifier, EpargneState>((ref) {
  final epargneRepository = ref.read(epargneRepositoryProvider);
  return EpargneNotifier(epargneRepository);
});