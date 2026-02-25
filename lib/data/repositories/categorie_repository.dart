import 'package:dio/dio.dart';
import 'package:monbudget/data/models/categorie_model.dart';
import 'package:monbudget/data/services/categorie_service.dart';

class CategorieRepository {
  final CategorieService _categorieService;
  CategorieRepository(this._categorieService);

  Future<CategorieModel> createCategorie({
    required String nom,
    required String icone,
  }) async {
    try {
      return await _categorieService.createCategorie(nom: nom, icone: icone);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur lors de la creaction',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }



  Future<List<CategorieModel>> getCategorie() async {
    try {
      return await _categorieService.getCategorie();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de recuperation des categories',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  // Seulement les catégories par défaut
Future<List<CategorieModel>> getCategoriesDefaut() async {
  final categories = await getCategorie();
  return categories.where((c) => c.estDefaut == true).toList();
}

// Seulement les catégories personnalisées
Future<List<CategorieModel>> getCategoriesPersonnalisees() async {
  final categories = await getCategorie();
  return categories.where((c) => c.estDefaut == false).toList();
}

  Future<void> deleteCategories(String categorieId) async {
    try {
      return await _categorieService.deleteCategories(categorieId);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de supression de categories',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<CategorieModel> updateCategorie(
    String categorieId,
    String? nom,
  ) async {
    try {
      return await _categorieService.updateCategorie(categorieId, nom);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de modification de categorie',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }
}
