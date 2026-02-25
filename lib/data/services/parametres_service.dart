import 'package:monbudget/core/config/api_client.dart';
import '../models/parametres_model.dart';

class ParametresService {
  final ApiClient _apiClient;

  ParametresService(this._apiClient);

  // ================= GET =================
  Future<ParametresModel> getParametres() async {
    final response = await _apiClient.dio.get('/parametres');

    return ParametresModel.fromJson(response.data);
  }

  // ================= PATCH =================
  Future<ParametresModel> updateParametres({
  String? theme,
  String? langue,
  bool? biometrie,
  bool? notificationsPush,
  bool? notificationsEmail,
}) async {
  final response = await _apiClient.dio.patch(
    '/parametres',
    data: {
      if (theme != null) 'theme': theme,
      if (langue != null) 'langue': langue,
      if (biometrie != null) 'biometrie': biometrie,
      if (notificationsPush != null)
        'notificationsPush': notificationsPush,
      if (notificationsEmail != null)
        'notificationsEmail': notificationsEmail,
    },
  );

  return ParametresModel.fromJson(response.data);
}
}