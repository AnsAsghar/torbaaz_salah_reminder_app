class QiblaDirection {
  final double direction;
  final double accuracy;
  final bool isAccurate;

  const QiblaDirection({
    required this.direction,
    required this.accuracy,
    required this.isAccurate,
  });

  factory QiblaDirection.fromJson(Map<String, dynamic> json) {
    return QiblaDirection(
      direction: json['direction'] as double,
      accuracy: json['accuracy'] as double,
      isAccurate: json['isAccurate'] as bool,
    );
  }
}
