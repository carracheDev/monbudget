import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:monbudget/core/config/api_client.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 Notification background: ${message.notification?.title}');
}

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔔 Permission: ${settings.authorizationStatus}');

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      'monbudget_channel',
      'MonBudget Notifications',
      description: 'Notifications MonBudget',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Notification foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    final token = await _messaging.getToken();
    print('🔑 FCM Token: $token');

    // ✅ Refresh automatique du token
    _messaging.onTokenRefresh.listen((newToken) async {
      print('🔄 Token refreshed: $newToken');
      await saveFcmToken(newToken);
    });
  }

  // ✅ Sauvegarder le token dans le backend
  static Future<void> saveFcmToken(String token) async {
    try {
      final apiClient = ApiClient();
      await apiClient.dio.post(
        '/auth/fcm-token',
        data: {'fcmToken': token},
      );
      print('✅ Token FCM sauvegardé');
    } catch (e) {
      print('❌ Erreur save token: $e');
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'monbudget_channel',
          'MonBudget Notifications',
          channelDescription: 'Notifications MonBudget',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}