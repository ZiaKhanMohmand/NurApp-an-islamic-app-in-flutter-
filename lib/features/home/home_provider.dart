import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'prayer_service.dart';
import 'notification_service.dart';
import 'package:nur_app/shared/providers/settings_provider.dart';

class HomeState {
  final PrayerTimes? prayerTimes;
  final String currentPrayer;
  final String nextPrayer;
  final String nextPrayerTime;
  final String qazaEnd;
  final String countdown;
  final String city;
  final bool loading;
  final bool showAdhan;
  final String? error;

  HomeState({
    this.prayerTimes,
    this.currentPrayer = 'Loading...',
    this.nextPrayer = '',
    this.nextPrayerTime = '00:00',
    this.qazaEnd = '00:00',
    this.countdown = '--:--:--',
    this.city = 'Locating...',
    this.loading = true,
    this.showAdhan = false,
    this.error,
  });

  HomeState copyWith({
    PrayerTimes? prayerTimes,
    String? currentPrayer,
    String? nextPrayer,
    String? nextPrayerTime,
    String? qazaEnd,
    String? countdown,
    String? city,
    bool? loading,
    bool? showAdhan,
    String? error,
  }) => HomeState(
    prayerTimes: prayerTimes ?? this.prayerTimes,
    currentPrayer: currentPrayer ?? this.currentPrayer,
    nextPrayer: nextPrayer ?? this.nextPrayer,
    nextPrayerTime: nextPrayerTime ?? this.nextPrayerTime,
    qazaEnd: qazaEnd ?? this.qazaEnd,
    countdown: countdown ?? this.countdown,
    city: city ?? this.city,
    loading: loading ?? this.loading,
    showAdhan: showAdhan ?? this.showAdhan,
    error: error,
  );
}

class HomeNotifier extends Notifier<HomeState> {
  Timer? _ticker;
  String _lastNotifiedPrayer = '';

  @override
  HomeState build() {
    ref.onDispose(() => _ticker?.cancel());
    ref.listen(settingsProvider, (prev, next) {
      if (prev?.madhab != next.madhab ||
          prev?.calculationMethod != next.calculationMethod) {
        refresh();
      }
    });
    _init();
    return HomeState();
  }

  Future<void> _init() async {
    try {
      final pos = await PrayerService.getLocation();
      final city = await PrayerService.getCityName(pos.latitude, pos.longitude);
      final settings = ref.read(settingsProvider);
      final method = _methodToInt(settings.calculationMethod);
      final school = settings.madhab == 'Hanafi' ? 1 : 0;

      final times = await PrayerService.fetchPrayerTimes(
        pos.latitude,
        pos.longitude,
        city,
        method: method,
        school: school,
      );

      final current = PrayerService.getCurrentPrayer(times);

      NotificationService.schedulePrayerNotifications(times).catchError((e) {
        print('Notification error (non-fatal): $e');
      });

      state = state.copyWith(
        prayerTimes: times,
        city: city,
        currentPrayer: current['current']!,
        nextPrayer: current['next']!,
        nextPrayerTime: current['nextTime']!,
        qazaEnd: current['qazaEnd']!,
        countdown: PrayerService.getCountdown(current['qazaEnd']!),
        loading: false,
      );

      _startTicker();
    } catch (e) {
      print('HOME INIT ERROR: $e');
      state = state.copyWith(
        loading: false,
        error: e.toString(),
        city: 'Mardan, PK',
      );
    }
  }

  int _methodToInt(String method) {
    switch (method) {
      case 'Muslim World League':
        return 1;
      case 'Islamic Society of North America':
        return 2;
      case 'Egyptian General Authority':
        return 3;
      case 'Umm Al-Qura University, Makkah':
        return 4;
      case 'University of Islamic Sciences, Karachi':
        return 18;
      default:
        return 1;
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.prayerTimes == null) return;

      final current = PrayerService.getCurrentPrayer(state.prayerTimes!);
      final newPrayer = current['current']!;
      final qazaEnd = current['qazaEnd']!;

      final showAdhan =
          newPrayer != _lastNotifiedPrayer && _lastNotifiedPrayer.isNotEmpty;

      if (showAdhan) {
        _lastNotifiedPrayer = newPrayer;
        state = state.copyWith(
          currentPrayer: newPrayer,
          nextPrayer: current['next']!,
          nextPrayerTime: current['nextTime']!,
          qazaEnd: qazaEnd,
          countdown: PrayerService.getCountdown(qazaEnd),
          showAdhan: true,
        );
        Timer(const Duration(seconds: 10), () {
          state = state.copyWith(showAdhan: false);
        });
      } else {
        if (_lastNotifiedPrayer.isEmpty) _lastNotifiedPrayer = newPrayer;
        state = state.copyWith(
          currentPrayer: newPrayer,
          nextPrayer: current['next']!,
          nextPrayerTime: current['nextTime']!,
          qazaEnd: qazaEnd,
          countdown: PrayerService.getCountdown(qazaEnd),
        );
      }
    });
  }

  Future<void> refresh() async {
    _ticker?.cancel();
    state = HomeState();
    await _init();
  }

  void dismissAdhan() => state = state.copyWith(showAdhan: false);
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
