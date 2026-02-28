import 'package:dio/dio.dart';
import 'package:monbudget/data/models/epargne_model.dart';
import 'package:monbudget/data/services/epargne_service.dart';

class EpargneRepository {
  final EpargneService _epargneService;

  EpargneRepository(this._epargneService);

  Future<List<EpargneModel>> getObjectifs() async {
    try {
      return await _epargneService.getObjectifs();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Erreur de recuperation d'objectif",
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<EpargneModel> createObjectif({
    required String nom,
    required String icone,
    required double montantCible,
    required DateTime dateEcheance,
  }) async {
    try {
      return await _epargneService.createObjectif(
        nom: nom,
        icone: icone,
        montantCible: montantCible,
        dateEcheance: dateEcheance,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Erreur de creaction d'objectif",
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<void> deleteObjectif(String epargneId) async {
    try {
      return await _epargneService.deleteObjectif(epargneId);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Erreur de suppression d'objectif",
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<EpargneModel> ajouterContribution({
    required String epargneId,
    required double montant,
  }) async {
    try {
      return await _epargneService.ajouterContribution(
        epargneId: epargneId,
        montant: montant,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Erreur lors d'ajout de Contribution",
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }
}
