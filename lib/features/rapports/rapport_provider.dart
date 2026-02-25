import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/data/repositories/rapport_repository.dart';

class RapportState {
  final Map<String, dynamic>? resume;
  final Map<String, dynamic>? categories;
  final Map<String, dynamic>? tendance;
  final bool isLoading;
  final String? error;

  RapportState({
    this.resume,
    this.categories,
    this.tendance,
    this.isLoading = false,
    this.error,
  });

  RapportState copyWith({
    Map<String, dynamic>? resume,
    Map<String, dynamic>? categories,
    Map<String, dynamic>? tendance,
    bool? isLoading,
    String? error,
  }) {
    return RapportState(
      resume: resume ?? this.resume,
      categories: categories ?? this.categories,
      tendance: tendance ?? this.tendance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RapportNotifier extends StateNotifier<RapportState> {
  final RapportRepository _rapportRepository;
  RapportNotifier(this._rapportRepository) : super(RapportState());

  Future<void> getResume({required String periode}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _rapportRepository.getResume(periode: periode);
      state = state.copyWith(isLoading: false, resume: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getCategories({required String periode}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _rapportRepository.getCategories(periode: periode);
      state = state.copyWith(isLoading: false, categories: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getTendance({required String periode}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _rapportRepository.getTendance(periode: periode);
      state = state.copyWith(isLoading: false, tendance: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> exportPdf({required String periode}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _rapportRepository.exportPdf(periode: periode);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

   Future<void> exportExcel({required String periode}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _rapportRepository.exportExcel(periode: periode);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ✅ Ajouter en bas
final rapportProvider =
    StateNotifierProvider<RapportNotifier, RapportState>((ref) {
  final rapportRepository = ref.read(rapportRepositoryProvider);
  return RapportNotifier(rapportRepository);
});