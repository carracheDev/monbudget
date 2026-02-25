import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/data/models/categorie_model.dart';
import 'package:monbudget/data/repositories/categorie_repository.dart';

// ================= STATE =================
class CategorieState {
  final List<CategorieModel> categories;
  final bool isLoading;
  final String? error;

  CategorieState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategorieState copyWith({
    List<CategorieModel>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategorieState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ================= NOTIFIER =================
class CategorieNotifier extends StateNotifier<CategorieState> {
  final CategorieRepository _categorieRepository;

  CategorieNotifier(this._categorieRepository) : super(CategorieState());

  Future<void> getCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _categorieRepository.getCategorie();
      state = state.copyWith(isLoading: false, categories: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createCategorie({
    required String nom,
    required String icone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _categorieRepository.createCategorie(nom: nom, icone: icone);
      await getCategories();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteCategorie(String categorieId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _categorieRepository.deleteCategories(categorieId);
      await getCategories();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ================= PROVIDER =================
final categorieProvider =
    StateNotifierProvider<CategorieNotifier, CategorieState>((ref) {
  final categorieRepository = ref.read(categorieRepositoryProvider);
  return CategorieNotifier(categorieRepository);
});
