import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'home_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final times = state.prayerTimes;

    final prayers = [
      {
        'name': 'Fajr',
        'time': times?.fajr ?? '--:--',
        'icon': Icons.wb_twilight_rounded,
        'active': state.currentPrayer.contains('Fajr'),
      },
      {
        'name': 'Dhuhr',
        'time': times?.dhuhr ?? '--:--',
        'icon': Icons.wb_sunny_rounded,
        'active': state.currentPrayer.contains('Dhuhr'),
      },
      {
        'name': 'Asr',
        'time': times?.asr ?? '--:--',
        'icon': Icons.sunny_snowing,
        'active': state.currentPrayer.contains('Asr'),
      },
      {
        'name': 'Maghrib',
        'time': times?.maghrib ?? '--:--',
        'icon': Icons.nights_stay_rounded,
        'active': state.currentPrayer.contains('Maghrib'),
      },
      {
        'name': 'Isha',
        'time': times?.isha ?? '--:--',
        'icon': Icons.dark_mode_rounded,
        'active': state.currentPrayer.contains('Isha'),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: state.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildAppBar(context, state)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 12),
                        _buildHeroCard(state),
                        const SizedBox(height: 20),
                        _buildPrayerTimesRow(prayers),
                        const SizedBox(height: 16),
                        _buildQiblaRamadanRow(context),
                        const SizedBox(height: 16),
                        _buildVerseCard(context),
                        const SizedBox(height: 16),
                        _buildMosqueCard(),
                        const SizedBox(height: 16),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAppBar(BuildContext context, HomeState state) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Islamic Date',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${now.day} ${_monthName(now.month)} ${now.year}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Expanded(
            child: Text(
              'NurApp',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
        ],
      ),
    );
  }

  String _monthName(int m) => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];

  Widget _buildHeroCard(HomeState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _CardPatternPainter())),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.gold,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.city,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                state.currentPrayer,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.countdown,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Next: ${state.nextPrayer} at ${state.nextPrayerTime}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesRow(List<Map<String, dynamic>> prayers) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Prayer Times',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Today',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: prayers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _PrayerCard(prayer: prayers[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildQiblaRamadanRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.go('/qibla'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'QIBLA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Icon(
                      Icons.explore_rounded,
                      color: AppColors.gold,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Tap to open',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RAMADAN DAY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerseCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('✦', style: TextStyle(color: AppColors.gold, fontSize: 16)),
              SizedBox(width: 10),
              Text(
                'Verse of the Day',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
              style: TextStyle(
                fontSize: 22,
                height: 1.8,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '"For indeed, with hardship [will be] ease."',
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: AppColors.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Surah Ash-Sharh, 94:5',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/reflection'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.surfaceVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'READ REFLECTION',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMosqueCard() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A2A1A), AppColors.primaryContainer],
        ),
      ),
      child: Stack(
        children: [
          const Center(child: Text('🕌', style: TextStyle(fontSize: 60))),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.navigation_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Nearby Mosques',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final Map<String, dynamic> prayer;
  const _PrayerCard({required this.prayer});

  @override
  Widget build(BuildContext context) {
    final active = prayer['active'] as bool;
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.goldLight : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? AppColors.gold : AppColors.surfaceVariant,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayer['name'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
          Icon(
            prayer['icon'] as IconData,
            color: active ? AppColors.primary : AppColors.onSurfaceVariant,
            size: 20,
          ),
          Text(
            prayer['time'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.primary : AppColors.onSurface,
            ),
          ),
          Icon(
            Icons.notifications_off_rounded,
            size: 14,
            color: active
                ? AppColors.primary
                : AppColors.onSurfaceVariant.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawLine(Offset(x, y - 8), Offset(x, y + 8), paint);
        canvas.drawLine(Offset(x - 8, y), Offset(x + 8, y), paint);
        canvas.drawLine(Offset(x - 6, y - 6), Offset(x + 6, y + 6), paint);
        canvas.drawLine(Offset(x + 6, y - 6), Offset(x - 6, y + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
