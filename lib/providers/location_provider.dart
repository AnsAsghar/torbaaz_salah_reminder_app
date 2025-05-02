import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

// Provider for the location service
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Provider for the current location data
final locationProvider = StateNotifierProvider<LocationNotifier, Map<String, dynamic>>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return LocationNotifier(locationService);
});

class LocationNotifier extends StateNotifier<Map<String, dynamic>> {
  final LocationService _locationService;

  LocationNotifier(this._locationService) : super({
    'latitude': LocationService.defaultLatitude,
    'longitude': LocationService.defaultLongitude,
    'city': LocationService.defaultCity,
    'country': LocationService.defaultCountry,
  }) {
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    try {
      final savedLocation = await _locationService.getSavedLocation();
      state = savedLocation;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading saved location: $e');
      }
    }
  }

  Future<bool> updateLocation({
    required double latitude,
    required double longitude,
    required String city,
    required String country,
  }) async {
    try {
      await _locationService.saveLocation(
        latitude: latitude,
        longitude: longitude,
        city: city,
        country: country,
      );

      state = {
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'country': country,
      };
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating location: $e');
      }
      return false;
    }
  }

  Future<bool> getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        // For simplicity, we'll just use the coordinates and set a generic city name
        // In a real app, you might want to use reverse geocoding to get the actual city name
        await updateLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          city: 'Current Location',
          country: '',
        );
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
      return false;
    }
  }
}
