import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/data/models/notification_model.dart';
import 'package:monbudget/data/repositories/notification_repository.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ================= NOTIFIER =================
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationNotifier(this._notificationRepository)
      : super(NotificationState());

  Future<void> getNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _notificationRepository.getNotifications();
      state = state.copyWith(isLoading: false, notifications: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> marquerCommeLue(String notificationId) async {
    try {
      await _notificationRepository.marquerCommeLue(notificationId);
      await getNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// ================= PROVIDER =================
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final notificationRepository = ref.read(notificationRepositoryProvider);
  return NotificationNotifier(notificationRepository);
});