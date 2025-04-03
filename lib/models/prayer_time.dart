class PrayerTime {
  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime? tahajjud;
  final String date;

  PrayerTime({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.tahajjud,
    required this.date,
  });

  static DateTime _parseTimeString(String timeStr, String dateStr) {
    // Split the time string into hours and minutes
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    // Parse the date string (assuming format like "01 Jan 2024")
    final dateParts = dateStr.split(' ');
    final day = int.parse(dateParts[0]);
    final month = _getMonthNumber(dateParts[1]);
    final year = int.parse(dateParts[2]);

    return DateTime(year, month, day, hours, minutes);
  }

  static int _getMonthNumber(String monthStr) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12
    };
    return months[monthStr] ?? 1;
  }

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    final dateStr = json['data']['date']['readable'] as String;
    final timings = json['data']['timings'];

    return PrayerTime(
      fajr: _parseTimeString(timings['Fajr'], dateStr),
      dhuhr: _parseTimeString(timings['Dhuhr'], dateStr),
      asr: _parseTimeString(timings['Asr'], dateStr),
      maghrib: _parseTimeString(timings['Maghrib'], dateStr),
      isha: _parseTimeString(timings['Isha'], dateStr),
      date: dateStr,
    );
  }

  Map<String, dynamic> toJson() => {
        'fajr':
            '${fajr.hour.toString().padLeft(2, '0')}:${fajr.minute.toString().padLeft(2, '0')}',
        'dhuhr':
            '${dhuhr.hour.toString().padLeft(2, '0')}:${dhuhr.minute.toString().padLeft(2, '0')}',
        'asr':
            '${asr.hour.toString().padLeft(2, '0')}:${asr.minute.toString().padLeft(2, '0')}',
        'maghrib':
            '${maghrib.hour.toString().padLeft(2, '0')}:${maghrib.minute.toString().padLeft(2, '0')}',
        'isha':
            '${isha.hour.toString().padLeft(2, '0')}:${isha.minute.toString().padLeft(2, '0')}',
        'tahajjud': tahajjud != null
            ? '${tahajjud!.hour.toString().padLeft(2, '0')}:${tahajjud!.minute.toString().padLeft(2, '0')}'
            : null,
        'date': date,
      };
}
