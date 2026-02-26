import 'package:monbudget/core/config/api_client.dart';
import 'package:monbudget/data/models/compte_model.dart';

class CompteService {
  final ApiClient _apiClient;

  CompteService(this._apiClient);

  Future<CompteModel> createCompte({
    required String nom,
    required CompteType type,
  }) async {
    final response = await _apiClient.dio.post(
      '/comptes',
      data: {'nom': nom, 'type': type.name},
    );
    return CompteModel.fromJson(response.data);
  }

  Future<List<CompteModel>> getCompte() async {
    final response = await _apiClient.dio.get('/comptes');
    return (response.data as List)
        .map((item) => CompteModel.fromJson(item))
        .toList();
  }

  Future<void> deleteCompte(String compteId) async {
    await _apiClient.dio.delete('/comptes/$compteId');
  }

  Future<CompteModel> updateCompte({
    required String compteId,
    String? nom,
  }) async {
    final response = await _apiClient.dio.patch(
      '/comptes/$compteId',
      data: {'nom': ?nom},
    );
    return CompteModel.fromJson(response.data);
  }

  Future<void> setDefaultCompte(String compteId) async {
    await _apiClient.dio.patch('/comptes/$compteId/defaut');
  }
}
