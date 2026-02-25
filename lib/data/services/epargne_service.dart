import 'package:monbudget/core/config/api_client.dart';
import 'package:monbudget/data/models/epargne_model.dart';

class EpargneService {
  final ApiClient _apiClient;
  EpargneService(this._apiClient);

  Future<List<EpargneModel>> getObjectifs() async {
    final response = await _apiClient.dio.get('/epargne');
    return (response.data as List)
        .map((item) => EpargneModel.fromJson(item))
        .toList();
  }

  Future<EpargneModel> createObjectif({
    required String nom,
    required String icone,
    required double montantCible,
  }) async {
    final response = await _apiClient.dio.post(
      '/epargne',
      data: {'nom': nom, 'icone': icone, 'montantCible': montantCible},
    );
    return EpargneModel.fromJson(response.data);
  }

  Future<void> deleteObjectif(String epargneId) async {
    await _apiClient.dio.delete('/epargne/$epargneId');
  }

  Future<EpargneModel> ajouterContribution({
    required String epargneId,
    required double montant,
  }) async {
    final response = await _apiClient.dio.post(
      '/epargne/contribution',
      data: {'objectifId': epargneId, 'montant': montant},
    );
    return EpargneModel.fromJson(response.data);
  }
}
