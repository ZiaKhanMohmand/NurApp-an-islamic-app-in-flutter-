import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'prayer_service.dart';

class HomeState {
  final PrayerTimes? prayerTimes;
  final String currentPrayer;
  final String nextPrayer;
  final String nextPrayerTime;
  final String countdown;
  final String city;
  final bool loading;
  final String? error;

  HomeState({
    this.prayerTimes,
    this.currentPrayer = 'Loading...',
    this.nextPrayer = '',
    this.nextPrayerTime = '00:00',
    this.countdown = '--:--:--',
    this.city = 'Locating...',
    this.loading = true,
    this.error,
  });

  HomeState copyWith({
    PrayerTimes? prayerTimes,
    String? currentPrayer,
    String? nextPrayer,
    String? nextPrayerTime,
    String? countdown,
    String? city,
    bool? loading,
    String? error,
  }) => HomeState(
    prayerTimes: prayerTimes ?? this.prayerTimes,
    currentPrayer: currentPrayer ?? this.currentPrayer,
    nextPrayer: nextPrayer ?? this.nextPrayer,
    nextPrayerTime: nextPrayerTime ?? this.nextPrayerTime,
    countdown: countdown ?? this.countdown,
    city: city ?? this.city,
    loading: loading ?? this.loading,
    error: error,
  );
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    _init();
    return HomeState();
  }

  Future<void> _init() async {
    try {
      final pos = await PrayerService.getLocation();
      final city = await PrayerService.getCityName(pos.latitude, pos.longitude);
      final times = await PrayerService.fetchPrayerTimes(
        pos.latitude,
        pos.longitude,
        city,
      );
      final current = PrayerService.getCurrentPrayer(times);

      state = state.copyWith(
        prayerTimes: times,
        city: city,
        currentPrayer: current['current']!,
        nextPrayer: current['next']!,
        nextPrayerTime: current['nextTime']!,
        countdown: PrayerService.getCountdown(current['nextTime']!),
        loading: false,
      );

      // Start countdown ticker
      _startTicker();
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
        city: 'Mardan, PK',
      );
    }
  }

  void _startTicker() {
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (state.nextPrayerTime.isNotEmpty) {
        state = state.copyWith(
          countdown: PrayerService.getCountdown(state.nextPrayerTime),
        );
      }
    });
  }

  Future<void> refresh() async {
    state = HomeState();
    await _init();
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
