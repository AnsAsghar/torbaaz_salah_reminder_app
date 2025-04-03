class CongregationTime {
  final String prayerName;
  final DateTime time;
  final int reminderMinutes;
  final bool isEnabled;
  final String mosqueName;
  final String? notes;

  CongregationTime({
    required this.prayerName,
    required this.time,
    this.reminderMinutes = 15,
    this.isEnabled = true,
    required this.mosqueName,
    this.notes,
  });

  factory CongregationTime.fromJson(Map<String, dynamic> json) {
    return CongregationTime(
      prayerName: json['prayerName'],
      time: DateTime.parse(json['time']),
      reminderMinutes: json['reminderMinutes'] ?? 15,
      isEnabled: json['isEnabled'] ?? true,
      mosqueName: json['mosqueName'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'prayerName': prayerName,
        'time': time.toIso8601String(),
        'reminderMinutes': reminderMinutes,
        'isEnabled': isEnabled,
        'mosqueName': mosqueName,
        'notes': notes,
      };

  CongregationTime copyWith({
    String? prayerName,
    DateTime? time,
    int? reminderMinutes,
    bool? isEnabled,
    String? mosqueName,
    String? notes,
  }) {
    return CongregationTime(
      prayerName: prayerName ?? this.prayerName,
      time: time ?? this.time,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isEnabled: isEnabled ?? this.isEnabled,
      mosqueName: mosqueName ?? this.mosqueName,
      notes: notes ?? this.notes,
    );
  }
}
