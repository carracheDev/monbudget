import 'package:dio/dio.dart';
import 'package:monbudget/data/models/portefeuille_model.dart';
import 'package:monbudget/data/models/recharge_model.dart';
import 'package:monbudget/data/services/portefeuille_service.dart';

class PortefeuilleRepository {
  final PortefeuilleService _portefeuilleService;
  PortefeuilleRepository(this._portefeuilleService);

  Future<PortefeuilleModel> getPortefeuille() async {
    try {
      return await _portefeuilleService.getPortefeuille();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de get Portfeuille',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<PortefeuilleModel> recharger({
    required double montant,
    required String operateur,
    required String numeroTelephone,
  }) async {
    try {
      return await _portefeuilleService.recharger(
        montant: montant,
        operateur: operateur,
        numeroTelephone: numeroTelephone,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de recharge');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<PortefeuilleModel> payer({
    required double montant,
    required String compteId,
    String? description,
  }) async {
    try {
      return await _portefeuilleService.payer(
        montant: montant,
        compteId: compteId,
        description: description,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de payer ');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<List<RechargeModel>> getRecharges() async {
    try {
      return await _portefeuilleService.getRecharges();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de get Recharges');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<List<Map<String, dynamic>>> getPaiements() async {
    try {
      return await _portefeuilleService.getPaiements();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de paiements');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }
}
