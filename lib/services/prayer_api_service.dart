import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/prayer_time.dart';

class PrayerApiService {
  static const String baseUrl = 'https://api.aladhan.com/v1';

  Future<PrayerTime> getPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    DateTime? date,
  }) async {
    date ??= DateTime.now();
    final formattedDate = '${date.day}-${date.month}-${date.year}';

    final url = Uri.parse(
        '$baseUrl/timings/$formattedDate?latitude=$latitude&longitude=$longitude&method=$method');

    try {
      if (kDebugMode) {
        print('Fetching prayer times from: $url');
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Response received: ${response.body}');
        }

        final data = json.decode(response.body);
        return PrayerTime.fromJson(data);
      } else {
        if (kDebugMode) {
          print('Error response: ${response.statusCode} - ${response.body}');
        }
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception caught: $e');
      }
      throw Exception('Failed to connect to prayer times service: $e');
    }
  }

  Future<PrayerTime> getPrayerTimesByAddress({
    required String address,
    required int method,
    DateTime? date,
  }) async {
    date ??= DateTime.now();
    final formattedDate = '${date.day}-${date.month}-${date.year}';

    final encodedAddress = Uri.encodeComponent(address);
    final url = Uri.parse(
        '$baseUrl/timingsByAddress/$formattedDate?address=$encodedAddress&method=$method');

    try {
      if (kDebugMode) {
        print('Fetching prayer times by address from: $url');
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Response received: ${response.body}');
        }

        final data = json.decode(response.body);
        return PrayerTime.fromJson(data);
      } else {
        if (kDebugMode) {
          print('Error response: ${response.statusCode} - ${response.body}');
        }
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception caught: $e');
      }
      throw Exception('Failed to connect to prayer times service: $e');
    }
  }
}
