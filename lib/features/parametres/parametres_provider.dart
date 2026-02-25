import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/data/models/parametres_model.dart';
import 'package:monbudget/data/repositories/parametres_repository.dart';

class ParametresState {
  final ParametresModel? parametre;
  final bool isLoading;
  final String? error;

  ParametresState({
    this.parametre,
    this.isLoading = false,
    this.error,
  });

  ParametresState copyWith({
    ParametresModel? parametre,
    bool? isLoading,
    String? error,
  }) {
    return ParametresState(
      parametre: parametre ?? this.parametre,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ================= NOTIFIER =================
class ParametresNotifier extends StateNotifier<ParametresState> {
  final ParametresRepository _parametresRepository;

  ParametresNotifier(this._parametresRepository) : super(ParametresState());

  Future<void> getParametres() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _parametresRepository.getParametres();
      state = state.copyWith(isLoading: false, parametre: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateParametres({
    String? theme,
    String? langue,
    bool? biometrie,
    bool? notificationsPush,
    bool? notificationsEmail,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _parametresRepository.updateParametres(
        theme: theme,
        langue: langue,
        biometrie: biometrie,
        notificationsPush: notificationsPush,
        notificationsEmail: notificationsEmail,
      );
      state = state.copyWith(isLoading: false, parametre: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ================= PROVIDER =================
final parametresProvider =
    StateNotifierProvider<ParametresNotifier, ParametresState>((ref) {
  final parametresRepository = ref.read(parametreRepositoryProvider);
  return ParametresNotifier(parametresRepository);
});
