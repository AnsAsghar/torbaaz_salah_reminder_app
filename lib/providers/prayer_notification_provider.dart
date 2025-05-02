import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/prayer_notification_service.dart';
import 'notification_provider.dart';

// Provider for the prayer notification service
final prayerNotificationServiceProvider = Provider<PrayerNotificationService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return PrayerNotificationService(notificationService);
});
