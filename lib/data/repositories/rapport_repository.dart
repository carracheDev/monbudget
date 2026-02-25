import 'package:dio/dio.dart';
import 'package:monbudget/data/services/rapport_service.dart';

class RapportRepository {
  final RapportService _rapportService;
  RapportRepository(this._rapportService);

  Future<Map<String, dynamic>> getResume({required String periode}) async {
    try {
      return await _rapportService.getResume(periode: periode);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de get Resume');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<Map<String, dynamic>> getCategories({required String periode}) async {
    try {
      return await _rapportService.getCategories(periode: periode);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de get Categories',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<Map<String, dynamic>> getTendance({required String periode}) async {
    try {
      return await _rapportService.getTendance(periode: periode);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de get Tendent');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<List<int>> exportPdf({required String periode}) async {
    try {
      return await _rapportService.exportPdf(periode: periode);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Erreur de l'exportPDf");
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

    Future<List<int>> exportExcel({required String periode}) async {
    try {
      return await _rapportService.exportExcel(periode: periode);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Erreur de l'exportExcel");
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

}
