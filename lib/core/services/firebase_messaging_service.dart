import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ✅ Handler pour les notifications en background (doit être top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 Notification background: ${message.notification?.title}');
}

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. Demander permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔔 Permission: ${settings.authorizationStatus}');

    // 2. Config notifications locales
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // 3. Canal Android
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

    // 4. Handler background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 5. Notification reçue app ouverte
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Notification foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 6. Récupérer le token FCM
    final token = await _messaging.getToken();
    print('🔑 FCM Token: $token');
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
