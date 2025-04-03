class UserPreferences {
  final String? location;
  final double? latitude;
  final double? longitude;
  final int calculationMethod;
  final bool isDarkMode;
  final Map<String, DateTime> congregationTimes;
  final bool enableNotifications;
  final int reminderMinutes;

  UserPreferences({
    this.location,
    this.latitude,
    this.longitude,
    this.calculationMethod = 2, // Default to Islamic Society of North America
    this.isDarkMode = false,
    Map<String, DateTime>? congregationTimes,
    this.enableNotifications = true,
    this.reminderMinutes = 10,
  }) : congregationTimes = congregationTimes ?? {};

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      calculationMethod: json['calculationMethod'] ?? 2,
      isDarkMode: json['isDarkMode'] ?? false,
      congregationTimes: Map<String, DateTime>.from(
        (json['congregationTimes'] ?? {}).map(
          (key, value) => MapEntry(key, DateTime.parse(value)),
        ),
      ),
      enableNotifications: json['enableNotifications'] ?? true,
      reminderMinutes: json['reminderMinutes'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'calculationMethod': calculationMethod,
        'isDarkMode': isDarkMode,
        'congregationTimes': congregationTimes.map(
          (key, value) => MapEntry(key, value.toIso8601String()),
        ),
        'enableNotifications': enableNotifications,
        'reminderMinutes': reminderMinutes,
      };

  UserPreferences copyWith({
    String? location,
    double? latitude,
    double? longitude,
    int? calculationMethod,
    bool? isDarkMode,
    Map<String, DateTime>? congregationTimes,
    bool? enableNotifications,
    int? reminderMinutes,
  }) {
    return UserPreferences(
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      congregationTimes: congregationTimes ?? this.congregationTimes,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }
}
