import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mosque_settings.dart';
import '../services/settings_service.dart';

// Provider for the settings service
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

// Provider for mosque settings
final mosqueSettingsProvider = StateNotifierProvider<MosqueSettingsNotifier, MosqueSettings>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return MosqueSettingsNotifier(settingsService);
});

class MosqueSettingsNotifier extends StateNotifier<MosqueSettings> {
  final SettingsService _settingsService;

  MosqueSettingsNotifier(this._settingsService) : super(MosqueSettings.defaultSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.getMosqueSettings();
      state = settings;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading mosque settings: $e');
      }
    }
  }

  Future<bool> updateSettings(MosqueSettings settings) async {
    try {
      final success = await _settingsService.saveMosqueSettings(settings);
      if (success) {
        state = settings;
      }
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating mosque settings: $e');
      }
      return false;
    }
  }

  Future<bool> updateCongregationOffset(String prayer, Duration offset) async {
    try {
      final updatedSettings = state.copyWith(
        congregationOffsets: {
          ...state.congregationOffsets,
          prayer: offset,
        },
      );
      
      final success = await _settingsService.saveMosqueSettings(updatedSettings);
      if (success) {
        state = updatedSettings;
      }
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating congregation offset: $e');
      }
      return false;
    }
  }
}
