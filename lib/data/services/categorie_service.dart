import 'package:monbudget/core/config/api_client.dart';
import 'package:monbudget/data/models/categorie_model.dart';

class CategorieService {
  final ApiClient _apiClient;

  CategorieService(this._apiClient);

  Future<CategorieModel> createCategorie({
    required String nom,
    required String icone,
  }) async {
    final response = await _apiClient.dio.post(
      '/categories',
      data: {'nom': nom, 'icone': icone},
    );
    return CategorieModel.fromJson(response.data);
  }

  Future<List<CategorieModel>> getCategorie() async {
    final response = await _apiClient.dio.get('/categories');
    return (response.data as List)
        .map((item) => CategorieModel.fromJson(item))
        .toList();
  }

  Future<void> deleteCategories(String categorieId) async {
    await _apiClient.dio.delete('/categories/$categorieId');
  }

  Future<CategorieModel> updateCategorie(
    String categorieId,
    String? nom,
  ) async {
    final response = await _apiClient.dio.patch(
      '/categories/$categorieId',
      data: {'nom': ?nom},
    );
    return CategorieModel.fromJson(response.data);
  }
}
