import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/data/models/notification_model.dart';
import 'package:monbudget/data/repositories/notification_repository.dart';
import 'package:monbudget/features/epargne/epargne_provider.dart';

class NotificationState {
  final List<NotificationModel> notification;
  final bool? isLoading;
  final String? error;

  NotificationState({
    this.notification = const [],
    this.isLoading = false,
    this.error,
  });
  NotificationState copyWith({
    List<NotificationModel>? notification,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notification: notification ?? this.notification,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ================= NOTIFIER =================
class NotificationNotifier extends StateNotifier {
  final NotificationRepository _notificationRepository;
  NotificationNotifier(this._notificationRepository)
    : super(NotificationState());

  Future<void> getNotifications() async {
    
  }
}
