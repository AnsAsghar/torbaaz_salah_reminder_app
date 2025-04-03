import 'package:flutter/material.dart';

class MosqueSettings {
  final String mosqueName;
  final Map<String, Duration> congregationOffsets;
  final String? address;
  final String? notes;

  MosqueSettings({
    required this.mosqueName,
    required this.congregationOffsets,
    this.address,
    this.notes,
  });

  // Default offsets from Adhan time to congregation time
  static Map<String, Duration> defaultOffsets = {
    'Fajr': Duration(minutes: 20),
    'Dhuhr': Duration(minutes: 15),
    'Asr': Duration(minutes: 15),
    'Maghrib': Duration(minutes: 5),
    'Isha': Duration(minutes: 15),
  };

  factory MosqueSettings.defaultSettings() {
    return MosqueSettings(
      mosqueName: 'Local Mosque',
      congregationOffsets: Map.from(defaultOffsets),
    );
  }

  DateTime getCongregationTime(String prayer, DateTime adhanTime) {
    final offset =
        congregationOffsets[prayer] ?? defaultOffsets[prayer] ?? Duration.zero;
    return adhanTime.add(offset);
  }

  factory MosqueSettings.fromJson(Map<String, dynamic> json) {
    return MosqueSettings(
      mosqueName: json['mosqueName'] as String,
      congregationOffsets: Map.fromEntries(
        (json['congregationOffsets'] as Map<String, dynamic>).entries.map(
              (e) => MapEntry(e.key, Duration(minutes: e.value as int)),
            ),
      ),
      address: json['address'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'mosqueName': mosqueName,
        'congregationOffsets': congregationOffsets.map(
          (key, value) => MapEntry(key, value.inMinutes),
        ),
        'address': address,
        'notes': notes,
      };

  MosqueSettings copyWith({
    String? mosqueName,
    Map<String, Duration>? congregationOffsets,
    String? address,
    String? notes,
  }) {
    return MosqueSettings(
      mosqueName: mosqueName ?? this.mosqueName,
      congregationOffsets:
          congregationOffsets ?? Map.from(this.congregationOffsets),
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }
}
