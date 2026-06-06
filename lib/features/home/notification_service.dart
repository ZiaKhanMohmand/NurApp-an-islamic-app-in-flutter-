import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'prayer_service.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  static Future<void> schedulePrayerNotifications(PrayerTimes times) async {
    await init();
    await _plugin.cancelAll();

    final prayers = [
      {'name': 'Fajr', 'time': times.fajr, 'id': 1},
      {'name': 'Dhuhr', 'time': times.dhuhr, 'id': 2},
      {'name': 'Asr', 'time': times.asr, 'id': 3},
      {'name': 'Maghrib', 'time': times.maghrib, 'id': 4},
      {'name': 'Isha', 'time': times.isha, 'id': 5},
    ];

    final now = DateTime.now();
    final isJumuah = now.weekday == DateTime.friday;

    for (final p in prayers) {
      final parts = (p['time'] as String).split(':');
      var scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final pName = p['name'] as String;
      final isDhuhr = pName == 'Dhuhr';
      final title = (isDhuhr && isJumuah)
          ? "Jumu'ah Mubarak 🕌"
          : "حَيَّ عَلَى الصَّلَاة — $pName";
      final body = (isDhuhr && isJumuah)
          ? "Time for Jumu'ah prayer. May Allah accept."
          : "Time for $pName prayer. Hayya 'alas-Salah!";

      await _plugin.zonedSchedule(
        id: p['id'] as int,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Times',
            channelDescription: 'Adhan notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}
