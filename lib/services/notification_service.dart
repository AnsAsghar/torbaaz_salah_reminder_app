import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Channel IDs
  static const String prayerChannelId = 'prayer_time_channel';
  static const String congregationChannelId = 'congregation_time_channel';

  // Notification IDs (we'll use these to identify and cancel notifications)
  static const int fajrPrayerId = 1;
  static const int dhuhrPrayerId = 2;
  static const int asrPrayerId = 3;
  static const int maghribPrayerId = 4;
  static const int ishaPrayerId = 5;

  static const int fajrCongregationId = 101;
  static const int dhuhrCongregationId = 102;
  static const int asrCongregationId = 103;
  static const int maghribCongregationId = 104;
  static const int ishaCongregationId = 105;

  // Sound file names
  static const String prayerSoundFile = 'adhan.mp3';
  static const String congregationSoundFile = 'congregation.mp3';

  // Initialize notifications
  Future<void> init() async {
    // Skip initialization on web platform
    if (kIsWeb) {
      if (kDebugMode) {
        print('Notification service not initialized on web platform');
      }
      return;
    }

    try {
      // Initialize timezone
      tz_data.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      final DarwinInitializationSettings iosInitSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          // Handle iOS notification when app is in foreground
        },
      );

      // Initialize settings
      final InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      // Initialize plugin
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
          // Handle notification tap
          if (kDebugMode) {
            print('Notification tapped: ${response.payload}');
          }
        },
      );

      // Create notification channels for Android
      await _createNotificationChannels();

      // Request notification permissions
      await _requestPermissions();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notification service: $e');
      }
    }
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    // Skip on web platform
    if (kIsWeb) return;

    try {
      if (Platform.isAndroid) {
        // Prayer time channel
        const AndroidNotificationChannel prayerChannel =
            AndroidNotificationChannel(
          prayerChannelId,
          'Prayer Time Notifications',
          description: 'Notifications for prayer times',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );

        // Congregation time channel
        const AndroidNotificationChannel congregationChannel =
            AndroidNotificationChannel(
          congregationChannelId,
          'Congregation Time Notifications',
          description: 'Notifications for congregation times',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

        // Create channels
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(prayerChannel);

        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(congregationChannel);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating notification channels: $e');
      }
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    // Skip on web platform
    if (kIsWeb) return;

    try {
      // For Android 13+ (API level 33)
      if (Platform.isAndroid) {
        await Permission.notification.request();
      }

      // For iOS
      if (Platform.isIOS) {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permissions: $e');
      }
    }
  }

  // Schedule prayer time notification
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Skip on web platform
    if (kIsWeb) {
      if (kDebugMode) {
        print('Notifications not supported on web platform');
      }
      return;
    }

    try {
      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        prayerChannelId,
        'Prayer Time Notifications',
        channelDescription: 'Notifications for prayer times',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('adhan'),
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'adhan.mp3',
      );

      // Notification details
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule notification
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      if (kDebugMode) {
        print(
            'Scheduled prayer notification for $title at ${scheduledTime.toString()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling prayer notification: $e');
      }
    }
  }

  // Schedule congregation time notification
  Future<void> scheduleCongregationNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Skip on web platform
    if (kIsWeb) {
      if (kDebugMode) {
        print('Notifications not supported on web platform');
      }
      return;
    }

    try {
      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        congregationChannelId,
        'Congregation Time Notifications',
        channelDescription: 'Notifications for congregation times',
        importance: Importance.high,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('congregation'),
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'congregation.mp3',
      );

      // Notification details
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule notification
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      if (kDebugMode) {
        print(
            'Scheduled congregation notification for $title at ${scheduledTime.toString()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling congregation notification: $e');
      }
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    // Skip on web platform
    if (kIsWeb) return;

    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      if (kDebugMode) {
        print('Error canceling all notifications: $e');
      }
    }
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    // Skip on web platform
    if (kIsWeb) return;

    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      if (kDebugMode) {
        print('Error canceling notification: $e');
      }
    }
  }

  // Get notification ID for prayer
  int getPrayerNotificationId(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return fajrPrayerId;
      case 'Dhuhr':
        return dhuhrPrayerId;
      case 'Asr':
        return asrPrayerId;
      case 'Maghrib':
        return maghribPrayerId;
      case 'Isha':
        return ishaPrayerId;
      default:
        return 0;
    }
  }

  // Get notification ID for congregation
  int getCongregationNotificationId(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return fajrCongregationId;
      case 'Dhuhr':
        return dhuhrCongregationId;
      case 'Asr':
        return asrCongregationId;
      case 'Maghrib':
        return maghribCongregationId;
      case 'Isha':
        return ishaCongregationId;
      default:
        return 0;
    }
  }
}
