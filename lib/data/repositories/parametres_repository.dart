import 'package:dio/dio.dart';
import 'package:monbudget/data/models/parametres_model.dart';
import 'package:monbudget/data/services/parametres_service.dart';

class ParametresRepository {
  final ParametresService _parametresService;
  ParametresRepository(this._parametresService);

  Future<ParametresModel> getParametres() async {
    try {
      return await _parametresService.getParametres();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de paramettre');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<ParametresModel> updateParametres({
    String? theme,
    String? langue,
    bool? biometrie,
    bool? notificationsPush,
    bool? notificationsEmail,
  }) async {
    try {
      return await _parametresService.updateParametres(
        theme: theme,
        langue: langue,
        biometrie: biometrie,
        notificationsPush: notificationsPush,
        notificationsEmail: notificationsEmail,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erreur de modification de parametre',
      );
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }
}
