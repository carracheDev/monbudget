import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/data/models/portefeuille_model.dart';
import 'package:monbudget/data/models/recharge_model.dart';
import 'package:monbudget/data/repositories/portefeuille_repository.dart';

class PortefeuilleState {
  final PortefeuilleModel? portefeuille;
  final List<RechargeModel> recharges;
  final List<Map<String, dynamic>> paiements; // ← ajouter
  final bool isLoading;
  final String? error;

  PortefeuilleState({
    this.portefeuille,
    this.recharges = const [],
    this.paiements = const [], // ← ajouter
    this.isLoading = false,
    this.error,
  });

  PortefeuilleState copyWith({
    PortefeuilleModel? portefeuille,
    List<RechargeModel>? recharges,
    List<Map<String, dynamic>>? paiements, // ← ajouter
    bool? isLoading,
    String? error,
  }) {
    return PortefeuilleState(
      portefeuille: portefeuille ?? this.portefeuille,
      recharges: recharges ?? this.recharges,
      paiements: paiements ?? this.paiements, // ← ajouter
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ================= NOTIFIER =================
class PortefeuilleNotifier extends StateNotifier<PortefeuilleState> {
  final PortefeuilleRepository _portefeuilleRepository;

  PortefeuilleNotifier(this._portefeuilleRepository)
      : super(PortefeuilleState());

  Future<void> getPortefeuille() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _portefeuilleRepository.getPortefeuille();
      state = state.copyWith(isLoading: false, portefeuille: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> recharger({
    required double montant,
    required String operateur,
    required String numeroTelephone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _portefeuilleRepository.recharger(
        montant: montant,
        operateur: operateur,
        numeroTelephone: numeroTelephone,
      );
      await getPortefeuille();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> payer({
    required double montant,
    required String compteId,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _portefeuilleRepository.payer(
        montant: montant,
        compteId: compteId,
        description: description,
      );
      await getPortefeuille();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getRecharges() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _portefeuilleRepository.getRecharges();
      state = state.copyWith(isLoading: false, recharges: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void>getPaiements()async{
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _portefeuilleRepository.getPaiements();
      state = state.copyWith(isLoading: false, paiements: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ================= PROVIDER =================
final portefeuilleProvider =
    StateNotifierProvider<PortefeuilleNotifier, PortefeuilleState>((ref) {
  final portefeuilleRepository = ref.read(portefeuilleRepositoryProvider);
  return PortefeuilleNotifier(portefeuilleRepository);
});