import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  // Default location (Dubai)
  static const double defaultLatitude = 25.2048;
  static const double defaultLongitude = 55.2708;
  static const String defaultCity = 'Dubai';
  static const String defaultCountry = 'UAE';

  // Save location to shared preferences
  Future<void> saveLocation({
    required double latitude,
    required double longitude,
    required String city,
    required String country,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', latitude);
      await prefs.setDouble('longitude', longitude);
      await prefs.setString('city', city);
      await prefs.setString('country', country);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving location: $e');
      }
    }
  }

  // Get saved location from shared preferences
  Future<Map<String, dynamic>> getSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latitude = prefs.getDouble('latitude') ?? defaultLatitude;
      final longitude = prefs.getDouble('longitude') ?? defaultLongitude;
      final city = prefs.getString('city') ?? defaultCity;
      final country = prefs.getString('country') ?? defaultCountry;

      return {
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'country': country,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting saved location: $e');
      }
      return {
        'latitude': defaultLatitude,
        'longitude': defaultLongitude,
        'city': defaultCity,
        'country': defaultCountry,
      };
    }
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    bool serviceEnabled;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      return serviceEnabled;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking location service: $e');
      }
      return false;
    }
  }

  // Check location permission
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking location permission: $e');
      }
      return LocationPermission.denied;
    }
  }

  // Request location permission
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting location permission: $e');
      }
      return LocationPermission.denied;
    }
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('Location services are disabled');
        }
        return null;
      }

      // Check location permission
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('Location permissions are permanently denied');
        }
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current position: $e');
      }
      return null;
    }
  }
}
