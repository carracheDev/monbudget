import 'package:dio/dio.dart';
import 'package:monbudget/data/models/compte_model.dart';
import 'package:monbudget/data/services/compte_service.dart';

class CompteRepository {
  final CompteService _compteService;
  CompteRepository(this._compteService);

  Future<CompteModel> createCompte({
    required String nom,
    required CompteType type,
  }) async {
    try {
      return await _compteService.createCompte(nom: nom, type: type);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de creaction de compte',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<List<CompteModel>> getCompte() async {
    try {
      return await _compteService.getCompte();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de recuperation de compte',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<void> deleteCompte(String compteId) async {
    try {
      return await _compteService.deleteCompte(compteId);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de suppression de compte',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<CompteModel> updateCompte({
    required String compteId,
    String? nom,
  }) async {
    try {
      return await _compteService.updateCompte(compteId: compteId, nom: nom);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de modification de compte',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<void> setDefaultCompte(String compteId) async {
    try {
      return await _compteService.setDefaultCompte(compteId);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de compte par defaut',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }
}
