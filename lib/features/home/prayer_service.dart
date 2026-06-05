import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PrayerTimes {
  final String fajr, dhuhr, asr, maghrib, isha, sunrise;
  final String city, country;

  PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.sunrise,
    required this.city,
    required this.country,
  });
}

class PrayerService {
  static Future<Position> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location disabled');

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw Exception('Permission denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  static Future<String> getCityName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return '${p.locality ?? p.subAdministrativeArea ?? 'Unknown'}, ${p.isoCountryCode ?? ''}';
      }
    } catch (_) {}
    return 'Unknown';
  }

  static Future<PrayerTimes> fetchPrayerTimes(
    double lat,
    double lng,
    String city,
  ) async {
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=4',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data['code'] != 200) throw Exception('API returned error');

    final timings = data['data']['timings'];

    return PrayerTimes(
      fajr: _format(timings['Fajr'] ?? '--:--'),
      dhuhr: _format(timings['Dhuhr'] ?? '--:--'),
      asr: _format(timings['Asr'] ?? '--:--'),
      maghrib: _format(timings['Maghrib'] ?? '--:--'),
      isha: _format(timings['Isha'] ?? '--:--'),
      sunrise: _format(timings['Sunrise'] ?? '--:--'),
      city: city,
      country: '',
    );
  }

  static String _format(String t) => t.split(' ').first;

  static DateTime _parseTime(String t, DateTime now) {
    final parts = t.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  static Map<String, String> getCurrentPrayer(PrayerTimes times) {
    final now = DateTime.now();
    final prayers = [
      {'name': 'Fajr', 'time': times.fajr},
      {'name': 'Dhuhr', 'time': times.dhuhr},
      {'name': 'Asr', 'time': times.asr},
      {'name': 'Maghrib', 'time': times.maghrib},
      {'name': 'Isha', 'time': times.isha},
    ];

    String current = 'Isha';
    String next = 'Fajr';
    String nextTime = times.fajr;

    for (int i = 0; i < prayers.length; i++) {
      final pTime = _parseTime(prayers[i]['time']!, now);
      if (now.isAfter(pTime)) {
        current = prayers[i]['name']!;
        if (i + 1 < prayers.length) {
          next = prayers[i + 1]['name']!;
          nextTime = prayers[i + 1]['time']!;
        }
      }
    }
    return {'current': current, 'next': next, 'nextTime': nextTime};
  }

  static String getCountdown(String nextPrayerTime) {
    final now = DateTime.now();
    final parts = nextPrayerTime.split(':');
    var target = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    final diff = target.difference(now);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
