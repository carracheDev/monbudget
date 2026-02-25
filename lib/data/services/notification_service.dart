import 'package:monbudget/core/config/api_client.dart';
import 'package:monbudget/data/models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.dio.get('/notifications');
    return (response.data as List)
        .map((item) => NotificationModel.fromJson(item))
        .toList();
  }

  Future<void> marquerCommeLue(String notificationId) async {
    await _apiClient.dio.post('/notifications/$notificationId/lue');
  }
}
