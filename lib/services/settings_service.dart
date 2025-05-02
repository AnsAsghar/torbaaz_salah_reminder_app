import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mosque_settings.dart';

class SettingsService {
  static const String _mosqueSettingsKey = 'mosque_settings';

  // Save mosque settings to shared preferences
  Future<bool> saveMosqueSettings(MosqueSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(settings.toJson());
      final result = await prefs.setString(_mosqueSettingsKey, jsonString);
      
      if (kDebugMode) {
        print('Saved mosque settings: $jsonString');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving mosque settings: $e');
      }
      return false;
    }
  }

  // Get saved mosque settings from shared preferences
  Future<MosqueSettings> getMosqueSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_mosqueSettingsKey);
      
      if (jsonString == null) {
        return MosqueSettings.defaultSettings();
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return MosqueSettings.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting mosque settings: $e');
      }
      return MosqueSettings.defaultSettings();
    }
  }
}
