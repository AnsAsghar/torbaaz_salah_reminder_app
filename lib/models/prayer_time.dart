import 'package:flutter/foundation.dart';

class PrayerTime {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime? nextPrayer;
  final String? nextPrayerName;

  const PrayerTime({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.nextPrayer,
    this.nextPrayerName,
  });

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    try {
      // Extract timings from the nested structure
      final timings = json['data']?['timings'];

      if (timings == null) {
        throw const FormatException(
            'Invalid API response format: missing data.timings');
      }

      // Get current date to combine with time strings
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);

      // Parse time strings in format "HH:MM"
      DateTime parseTimeString(String timeStr) {
        try {
          final parts = timeStr.split(':');
          if (parts.length != 2) {
            throw FormatException('Invalid time format: $timeStr');
          }

          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          return DateTime(date.year, date.month, date.day, hour, minute);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing time string: $timeStr - $e');
          }
          // Return a default time if parsing fails
          return date;
        }
      }

      // Safely get prayer time with fallback
      DateTime getPrayerTime(String key) {
        try {
          final timeStr = timings[key];
          if (timeStr == null) {
            if (kDebugMode) {
              print('Missing prayer time for $key');
            }
            return date;
          }
          return parseTimeString(timeStr);
        } catch (e) {
          if (kDebugMode) {
            print('Error getting prayer time for $key: $e');
          }
          return date;
        }
      }

      // Calculate next prayer
      DateTime? nextPrayer;
      String? nextPrayerName;

      return PrayerTime(
        fajr: getPrayerTime('Fajr'),
        sunrise: getPrayerTime('Sunrise'),
        dhuhr: getPrayerTime('Dhuhr'),
        asr: getPrayerTime('Asr'),
        maghrib: getPrayerTime('Maghrib'),
        isha: getPrayerTime('Isha'),
        nextPrayer: nextPrayer,
        nextPrayerName: nextPrayerName,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing prayer times: $e');
      }
      // Return default prayer times if parsing fails completely
      final now = DateTime.now();
      return PrayerTime(
        fajr: now,
        sunrise: now,
        dhuhr: now,
        asr: now,
        maghrib: now,
        isha: now,
      );
    }
  }
}
