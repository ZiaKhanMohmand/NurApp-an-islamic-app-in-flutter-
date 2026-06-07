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
    if (perm == LocationPermission.deniedForever) {
      throw Exception('Permission permanently denied');
    }
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw Exception('Permission denied');
      }
    }
    // already granted — skip request entirely
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
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
    String city, {
    int method = 1,
    int school = 1,
  }) async {
    // method=1 = Muslim World League — correct for Pakistan/KPK
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=$method&school=$school',
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

  /// Returns current prayer + countdown target = END of current prayer window (qaza time)
  static Map<String, String> getCurrentPrayer(PrayerTimes times) {
    final now = DateTime.now();

    // Prayer name → its START time
    final starts = [
      {'name': 'Fajr', 'time': times.fajr},
      {'name': 'Sunrise', 'time': times.sunrise}, // marks Fajr qaza end
      {'name': 'Dhuhr', 'time': times.dhuhr},
      {'name': 'Asr', 'time': times.asr},
      {'name': 'Maghrib', 'time': times.maghrib},
      {'name': 'Isha', 'time': times.isha},
    ];

    // Qaza window end for each prayer:
    // Fajr   → Sunrise
    // Dhuhr  → Asr
    // Asr    → Maghrib
    // Maghrib→ Isha
    // Isha   → Fajr next day
    final qazaEnds = {
      'Fajr': times.sunrise,
      'Dhuhr': times.asr,
      'Asr': times.maghrib,
      'Maghrib': times.isha,
      'Isha': times.fajr, // next day handled in getCountdown
    };

    final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    String current = 'Isha';
    String next = 'Fajr';
    String nextTime = times.fajr;
    String qazaEnd = times.fajr; // default: Isha qaza ends at Fajr

    final fajr = _parseTime(times.fajr, now);
    final sunrise = _parseTime(times.sunrise, now);
    final dhuhr = _parseTime(times.dhuhr, now);
    final asr = _parseTime(times.asr, now);
    final maghrib = _parseTime(times.maghrib, now);
    final isha = _parseTime(times.isha, now);

    if (now.isBefore(fajr)) {
      // Before Fajr — still in Isha window from yesterday
      current = 'Isha';
      next = 'Fajr';
      nextTime = times.fajr;
      qazaEnd = times.fajr;
    } else if (now.isBefore(sunrise)) {
      current = 'Fajr';
      next = 'Dhuhr';
      nextTime = times.dhuhr;
      qazaEnd = times.sunrise;
    } else if (now.isBefore(dhuhr)) {
      // Between Sunrise and Dhuhr — no active fard prayer
      current = 'Dhuhr'; // upcoming
      next = 'Dhuhr';
      nextTime = times.dhuhr;
      qazaEnd = times.dhuhr; // countdown to Dhuhr start
    } else if (now.isBefore(asr)) {
      current = 'Dhuhr';
      next = 'Asr';
      nextTime = times.asr;
      qazaEnd = times.asr;
    } else if (now.isBefore(maghrib)) {
      current = 'Asr';
      next = 'Maghrib';
      nextTime = times.maghrib;
      qazaEnd = times.maghrib;
    } else if (now.isBefore(isha)) {
      current = 'Maghrib';
      next = 'Isha';
      nextTime = times.isha;
      qazaEnd = times.isha;
    } else {
      current = 'Isha';
      next = 'Fajr';
      nextTime = times.fajr;
      qazaEnd = times.fajr; // tomorrow Fajr
    }

    return {
      'current': current,
      'next': next,
      'nextTime': nextTime,
      'qazaEnd': qazaEnd, // countdown target
    };
  }

  /// Countdown to qazaEnd (end of current prayer window)
  static String getCountdown(String qazaEndTime) {
    final now = DateTime.now();
    final parts = qazaEndTime.split(':');
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

  static bool isPrayerTime(PrayerTimes times) {
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    for (final t in [
      times.fajr,
      times.dhuhr,
      times.asr,
      times.maghrib,
      times.isha,
    ]) {
      final parts = t.split(':');
      final pMins = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (nowMins == pMins) return true;
    }
    return false;
  }
}
