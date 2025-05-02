import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/prayer_time.dart';

class PrayerApiService {
  static const String baseUrl = 'https://api.aladhan.com/v1';
  static const int timeoutSeconds = 10;

  Future<PrayerTime> getPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    DateTime? date,
  }) async {
    date ??= DateTime.now();
    final formattedDate = '${date.day}-${date.month}-${date.year}';

    // Use the timingsByCity endpoint which is more reliable
    final url = Uri.parse(
        '$baseUrl/timings/$formattedDate?latitude=$latitude&longitude=$longitude&method=$method');

    try {
      if (kDebugMode) {
        print('Fetching prayer times from: $url');
      }

      final response = await http.get(url).timeout(
        const Duration(seconds: timeoutSeconds),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

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
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('Socket exception: $e');
      }
      throw Exception(
          'Network error: Please check your internet connection. Details: ${e.message}');
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('Timeout exception: $e');
      }
      throw Exception(
          'Connection timed out: Server is taking too long to respond');
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('Format exception: $e');
      }
      throw Exception('Invalid response format from server: $e');
    } on HttpException catch (e) {
      if (kDebugMode) {
        print('HTTP exception: $e');
      }
      throw Exception('HTTP error occurred: $e');
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

      final response = await http.get(url).timeout(
        const Duration(seconds: timeoutSeconds),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

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
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('Socket exception: $e');
      }
      throw Exception(
          'Network error: Please check your internet connection. Details: ${e.message}');
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('Timeout exception: $e');
      }
      throw Exception(
          'Connection timed out: Server is taking too long to respond');
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('Format exception: $e');
      }
      throw Exception('Invalid response format from server: $e');
    } on HttpException catch (e) {
      if (kDebugMode) {
        print('HTTP exception: $e');
      }
      throw Exception('HTTP error occurred: $e');
    } catch (e) {
      if (kDebugMode) {
        print('Exception caught: $e');
      }
      throw Exception('Failed to connect to prayer times service: $e');
    }
  }

  // New method that uses the API key you provided
  Future<PrayerTime> getPrayerTimesByCity({
    required String city,
    required String country,
    required int method,
    DateTime? date,
  }) async {
    date ??= DateTime.now();
    final formattedDate = '${date.day}-${date.month}-${date.year}';

    final address = '$city,$country';
    final encodedAddress = Uri.encodeComponent(address);

    // Using the API URL you provided
    final url = Uri.parse(
        '$baseUrl/timingsByAddress/$formattedDate?address=$encodedAddress&method=$method&tune=2,3,4,5,2,3,4,5,-3');

    try {
      if (kDebugMode) {
        print('Fetching prayer times by city from: $url');
      }

      final response = await http.get(url).timeout(
        const Duration(seconds: timeoutSeconds),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

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
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('Socket exception: $e');
      }
      throw Exception(
          'Network error: Please check your internet connection. Details: ${e.message}');
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('Timeout exception: $e');
      }
      throw Exception(
          'Connection timed out: Server is taking too long to respond');
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('Format exception: $e');
      }
      throw Exception('Invalid response format from server: $e');
    } on HttpException catch (e) {
      if (kDebugMode) {
        print('HTTP exception: $e');
      }
      throw Exception('HTTP error occurred: $e');
    } catch (e) {
      if (kDebugMode) {
        print('Exception caught: $e');
      }
      throw Exception('Failed to connect to prayer times service: $e');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
