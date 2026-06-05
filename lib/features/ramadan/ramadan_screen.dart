import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../home/prayer_service.dart';
import 'package:geolocator/geolocator.dart';

class RamadanScreen extends StatefulWidget {
  const RamadanScreen({super.key});
  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen> {
  String _suhoorTime = '--:--';
  String _iftarTime = '--:--';
  String _suhoorCountdown = '--:--:--';
  String _iftarCountdown = '--:--:--';
  int _ramadanDay = 0;
  bool _isRamadan = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      final times = await PrayerService.fetchPrayerTimes(
        pos.latitude,
        pos.longitude,
        '',
      );

      // Suhoor = Fajr time, Iftar = Maghrib time
      final hijri = HijriCalendar.fromDate(DateTime.now());
      final isRamadan = hijri.hMonth == 9;
      final ramadanDay = isRamadan ? hijri.hDay : 0;

      setState(() {
        _suhoorTime = times.fajr;
        _iftarTime = times.maghrib;
        _isRamadan = isRamadan;
        _ramadanDay = ramadanDay;
      });

      _startTimer();
    } catch (_) {}
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _suhoorCountdown = _getCountdown(_suhoorTime);
        _iftarCountdown = _getCountdown(_iftarTime);
      });
    });
  }

  String _getCountdown(String time) {
    if (time == '--:--' || time.isEmpty) return '--:--:--';
    final parts = time.split(':');
    if (parts.length < 2) return '--:--:--';
    try {
      final now = DateTime.now();
      var target = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      if (target.isBefore(now)) target = target.add(const Duration(days: 1));
      final diff = target.difference(now);
      final h = diff.inHours.toString().padLeft(2, '0');
      final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    } catch (_) {
      return '--:--:--';
    }
  }

  bool _isSoon(String countdown) {
    if (countdown.contains('-')) return false;
    final parts = countdown.split(':');
    if (parts.length < 3) return false;
    try {
      return int.parse(parts[0]) == 0 && int.parse(parts[1]) < 30;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_rounded, color: Colors.white),
                    const Expanded(
                      child: Text(
                        'NurApp',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              // Hero section
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'Ramadan Kareem',
                          style: TextStyle(
                            fontSize: 22,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Day badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            _isRamadan
                                ? 'DAY $_ramadanDay OF 30'
                                : 'NOT RAMADAN YET',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Progress bar
                        if (_isRamadan)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _ramadanDay / 30,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.gold,
                              ),
                              minHeight: 6,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Crescent decoration
                  Positioned(
                    top: 0,
                    right: 16,
                    child: Text(
                      '☽',
                      style: TextStyle(
                        fontSize: 80,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),

              // Suhoor + Iftar cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _TimeCard(
                        label: 'Next Suhoor',
                        time: _suhoorTime,
                        countdown: _suhoorCountdown,
                        isSoon: _isSoon(_suhoorCountdown),
                        period: 'AM',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeCard(
                        label: 'Today\'s Iftar',
                        time: _iftarTime,
                        countdown: _iftarCountdown,
                        isSoon: _isSoon(_iftarCountdown),
                        period: 'PM',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Dua for Iftar card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Dua for Iftar',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللّٰه',
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '"The thirst has gone, the veins are moistened, and the reward is confirmed, if Allah wills."',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.gold,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.volume_up_rounded, size: 18),
                          label: const Text('Listen to Dua'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldLight,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Daily Reflection card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            '✦',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Daily Reflection',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '"Ramadan is not just about staying hungry. It\'s about feeding the soul with patience, kindness, and gratitude. Let today be the day you forgive one person who hurt you."',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.7,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '— Imam Al-Ghazali Reflections',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Icon(
                                    Icons.share_rounded,
                                    color: AppColors.gold,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String label, time, countdown, period;
  final bool isSoon;
  const _TimeCard({
    required this.label,
    required this.time,
    required this.countdown,
    required this.period,
    required this.isSoon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          // Circular countdown
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      period,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSoon ? Icons.alarm_rounded : Icons.access_time_rounded,
                color: AppColors.gold,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                isSoon ? 'Soon' : 'in $countdown',
                style: TextStyle(
                  fontSize: 12,
                  color: isSoon ? AppColors.gold : Colors.white70,
                  fontWeight: isSoon ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
