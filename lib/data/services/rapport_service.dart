import 'package:dio/dio.dart';
import 'package:monbudget/core/config/api_client.dart';

class RapportService {
  final ApiClient _apiClient;
  RapportService(this._apiClient);

  Future<Map<String, dynamic>> getResume({required String periode}) async {
    final response = await _apiClient.dio.get(
      '/rapports/resume',
      queryParameters: {'periode': periode},
    );
    return response.data;
  }

  // getCategories depenses par patégorie
  Future<Map<String, dynamic>> getCategories({required String periode}) async {
    final response = await _apiClient.dio.get(
      '/rapports/categories',
      queryParameters: {'periode': periode},
    );
    return response.data;
  }

   // getTendance tendance des mois
  Future<Map<String, dynamic>> getTendance({required String periode}) async {
    final response = await _apiClient.dio.get(
      '/rapports/tendance',
      queryParameters: {'periode': periode},
    );
    return response.data;
  }

     Future<List<int>> exportPdf({required String periode}) async {
    final response = await _apiClient.dio.get(
      '/rapports/export/pdf',
      queryParameters: {'periode': periode},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }


  Future<List<int>> exportExcel({required String periode}) async {
    final response = await _apiClient.dio.get(
      '/rapports/export/excel',
      queryParameters: {'periode': periode},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }

}
