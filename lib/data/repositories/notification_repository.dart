import 'package:dio/dio.dart';
import 'package:monbudget/data/models/notification_model.dart';
import 'package:monbudget/data/services/notification_service.dart';

class NotificationRepository {
  final NotificationService _notificationService;
  NotificationRepository(this._notificationService);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      return await _notificationService.getNotifications();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de notification');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<void> marquerCommeLue(String notificationId) async {
    try {
      return await _notificationService.marquerCommeLue(notificationId);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de notification');
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }
}
