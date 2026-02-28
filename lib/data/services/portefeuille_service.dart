import 'package:monbudget/core/config/api_client.dart';
import 'package:monbudget/data/models/portefeuille_model.dart';
import 'package:monbudget/data/models/recharge_model.dart';

class PortefeuilleService {
  final ApiClient _apiClient;

  PortefeuilleService(this._apiClient);

  Future<PortefeuilleModel> getPortefeuille() async {
    final response = await _apiClient.dio.get('/portefeuille');
    return PortefeuilleModel.fromJson(response.data);
  }

  Future<PortefeuilleModel> recharger({
    required double montant,
    required String operateur,
    required String numeroTelephone,
  }) async {
    final response = await _apiClient.dio.post(
      '/portefeuille/recharger',
      data: {
        'montant': montant,
        'operateur': operateur,
        'numeroTelephone': numeroTelephone,
      },
    );
    return PortefeuilleModel.fromJson(response.data);
  }

  Future<PortefeuilleModel> payer({
    required double montant,
    required String compteId,
    String? description,
  }) async {
    final response = await _apiClient.dio.post(
      '/portefeuille/payer',
      data: {
        'montant': montant,
        'compteId': compteId,
        if (description != null) 'description': description,
      },
    );

    return PortefeuilleModel.fromJson(response.data);
  }

  Future<List<RechargeModel>> getRecharges() async {
    final response = await _apiClient.dio.get('/portefeuille/recharges');

    final List data = response.data;

    return data.map((json) => RechargeModel.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getPaiements() async {
    final response = await _apiClient.dio.get('/portefeuille/paiements');
    return List<Map<String, dynamic>>.from(response.data);
  }
}
