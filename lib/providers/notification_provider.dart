import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provider for notification settings
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettings {
  final bool enablePrayerNotifications;
  final bool enableCongregationNotifications;
  final int reminderMinutes;

  NotificationSettings({
    this.enablePrayerNotifications = true,
    this.enableCongregationNotifications = true,
    this.reminderMinutes = 10,
  });

  NotificationSettings copyWith({
    bool? enablePrayerNotifications,
    bool? enableCongregationNotifications,
    int? reminderMinutes,
  }) {
    return NotificationSettings(
      enablePrayerNotifications: enablePrayerNotifications ?? this.enablePrayerNotifications,
      enableCongregationNotifications: enableCongregationNotifications ?? this.enableCongregationNotifications,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(NotificationSettings());

  void togglePrayerNotifications(bool value) {
    state = state.copyWith(enablePrayerNotifications: value);
  }

  void toggleCongregationNotifications(bool value) {
    state = state.copyWith(enableCongregationNotifications: value);
  }

  void setReminderMinutes(int minutes) {
    state = state.copyWith(reminderMinutes: minutes);
  }
}
