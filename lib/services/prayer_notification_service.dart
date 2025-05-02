import 'package:flutter/foundation.dart';
import '../models/prayer_time.dart';
import '../models/mosque_settings.dart';
import 'notification_service.dart';

class PrayerNotificationService {
  final NotificationService _notificationService;

  PrayerNotificationService(this._notificationService);

  // Schedule notifications for all prayer times
  Future<void> schedulePrayerNotifications(
    PrayerTime prayerTimes, {
    bool enablePrayerNotifications = true,
    bool enableCongregationNotifications = true,
    MosqueSettings? mosqueSettings,
  }) async {
    // Skip on web platform
    if (kIsWeb) {
      if (kDebugMode) {
        print('Prayer notifications not supported on web platform');
      }
      return;
    }

    try {
      // Cancel existing notifications first
      await _notificationService.cancelAllNotifications();

      if (!enablePrayerNotifications && !enableCongregationNotifications) {
        if (kDebugMode) {
          print(
              'All notifications are disabled. Not scheduling any notifications.');
        }
        return;
      }

      final prayers = {
        'Fajr': prayerTimes.fajr,
        'Dhuhr': prayerTimes.dhuhr,
        'Asr': prayerTimes.asr,
        'Maghrib': prayerTimes.maghrib,
        'Isha': prayerTimes.isha,
      };

      // Schedule notifications for each prayer time
      for (final entry in prayers.entries) {
        final prayerName = entry.key;
        final adhanTime = entry.value;

        // Only schedule notifications for future prayer times
        if (adhanTime.isAfter(DateTime.now())) {
          // Schedule prayer time notification
          if (enablePrayerNotifications) {
            await _schedulePrayerNotification(prayerName, adhanTime);
          }

          // Schedule congregation time notification if mosque settings are provided
          if (enableCongregationNotifications && mosqueSettings != null) {
            final congregationTime =
                mosqueSettings.getCongregationTime(prayerName, adhanTime);

            // Only schedule if congregation time is in the future
            if (congregationTime.isAfter(DateTime.now())) {
              await _scheduleCongregationNotification(
                  prayerName, congregationTime);
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling prayer notifications: $e');
      }
    }
  }

  // Schedule a notification for prayer time
  Future<void> _schedulePrayerNotification(
      String prayerName, DateTime prayerTime) async {
    final id = _notificationService.getPrayerNotificationId(prayerName);

    await _notificationService.schedulePrayerNotification(
      id: id,
      title: '$prayerName Prayer Time',
      body: 'It\'s time for $prayerName prayer',
      scheduledTime: prayerTime,
      payload: 'prayer_$prayerName',
    );
  }

  // Schedule a notification for congregation time
  Future<void> _scheduleCongregationNotification(
      String prayerName, DateTime congregationTime) async {
    final id = _notificationService.getCongregationNotificationId(prayerName);

    await _notificationService.scheduleCongregationNotification(
      id: id,
      title: '$prayerName Congregation',
      body: 'It\'s time for $prayerName congregation prayer',
      scheduledTime: congregationTime,
      payload: 'congregation_$prayerName',
    );
  }
}
