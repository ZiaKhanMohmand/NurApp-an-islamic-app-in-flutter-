import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Static data for now — Phase 3B will make this live
  final String _city = 'Mardan, PK';
  final String _hijriDate = '7 Dhul Hijjah 1446';
  final String _gregDate = '4 JUNE 2025';
  final String _currentPrayer = 'Asr Prayer';
  final String _countdown = '02:45:08';
  final String _nextPrayer = 'Maghrib at 18:12';
  final double _qiblaAngle = 254.3;

  final List<Map<String, dynamic>> _prayers = [
    {
      'name': 'Fajr',
      'time': '04:42',
      'icon': Icons.wb_twilight_rounded,
      'active': false,
    },
    {
      'name': 'Dhuhr',
      'time': '12:05',
      'icon': Icons.wb_sunny_rounded,
      'active': false,
    },
    {
      'name': 'Asr',
      'time': '15:32',
      'icon': Icons.sunny_snowing,
      'active': true,
    },
    {
      'name': 'Maghrib',
      'time': '18:12',
      'icon': Icons.nights_stay_rounded,
      'active': false,
    },
    {
      'name': 'Isha',
      'time': '19:45',
      'icon': Icons.dark_mode_rounded,
      'active': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(child: _buildAppBar()),
            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 12),
                  _buildHeroCard(),
                  const SizedBox(height: 20),
                  _buildPrayerTimesRow(),
                  const SizedBox(height: 16),
                  _buildQiblaRamadanRow(),
                  const SizedBox(height: 16),
                  _buildVerseCard(),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _hijriDate,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                _gregDate,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.5,
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
          IconButton(
            icon: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
            ),
            onPressed: () => context.go('/calendar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Subtle pattern
          Positioned.fill(child: CustomPaint(painter: _CardPatternPainter())),
          Column(
            children: [
              // City
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
                    _city,
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
              // Current prayer
              Text(
                _currentPrayer,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Countdown
              Text(
                _countdown,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Next: $_nextPrayer',
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

  Widget _buildPrayerTimesRow() {
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
            itemCount: _prayers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _PrayerCard(prayer: _prayers[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildQiblaRamadanRow() {
    return Row(
      children: [
        // Qibla mini card
        Expanded(
          child: GestureDetector(
            onTap: () => context.go('/qibla'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant, width: 1),
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
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                      ),
                      child: const Icon(
                        Icons.explore_rounded,
                        color: AppColors.gold,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '${_qiblaAngle}° SW',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Ramadan day card
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
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '14',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: ' / 30',
                        style: TextStyle(fontSize: 16, color: AppColors.gold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 14 / 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Iftar in 3h 27m',
                  style: TextStyle(fontSize: 12, color: AppColors.gold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerseCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.goldLight.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '✦',
                        style: TextStyle(color: AppColors.gold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Verse of the Day',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.menu_book_outlined,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Arabic text
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
          // Read reflection button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
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

// Prayer time card widget
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

// Card background pattern
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
