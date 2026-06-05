import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nur_app/core/l10n/app_strings.dart';
import 'package:nur_app/features/reflection/reflection_service.dart';
import '../../core/theme/app_colors.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ReflectionData? _reflection;
  bool _reflectionLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReflection();
  }

  Future<void> _loadReflection() async {
    try {
      final r = await ReflectionService.fetchReflection(
        isArabic: ref.read(stringsProvider).isArabic,
      );
      if (!mounted) return;
      setState(() {
        _reflection = r;
        _reflectionLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _reflectionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final s = ref.watch(stringsProvider);
    final times = state.prayerTimes;

    final prayers = [
      {
        'name': s.fajr,
        'time': times?.fajr ?? '--:--',
        'icon': Icons.wb_twilight_rounded,
        'active': state.currentPrayer == 'Fajr',
      },
      {
        'name': s.dhuhr,
        'time': times?.dhuhr ?? '--:--',
        'icon': Icons.wb_sunny_rounded,
        'active': state.currentPrayer == 'Dhuhr',
      },
      {
        'name': s.asr,
        'time': times?.asr ?? '--:--',
        'icon': Icons.sunny_snowing,
        'active': state.currentPrayer == 'Asr',
      },
      {
        'name': s.maghrib,
        'time': times?.maghrib ?? '--:--',
        'icon': Icons.nights_stay_rounded,
        'active': state.currentPrayer == 'Maghrib',
      },
      {
        'name': s.isha,
        'time': times?.isha ?? '--:--',
        'icon': Icons.dark_mode_rounded,
        'active': state.currentPrayer == 'Isha',
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
                  SliverToBoxAdapter(child: _buildAppBar(context, state, s)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 12),
                        _buildHeroCard(state, s),
                        const SizedBox(height: 20),
                        _buildPrayerTimesRow(prayers, s),
                        const SizedBox(height: 16),
                        _buildQiblaRamadanRow(context, s),
                        const SizedBox(height: 16),
                        _buildVerseCard(
                          context,
                          s,
                          _reflection,
                          _reflectionLoading,
                        ),
                        const SizedBox(height: 16),
                        _buildMosqueCard(s),
                        const SizedBox(height: 16),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAppBar(BuildContext context, HomeState state, AppStrings s) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.today,
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
          GestureDetector(
            onTap: () => context.go('/calendar'),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
            ),
          ),
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

  Widget _buildHeroCard(HomeState state, AppStrings s) {
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
                translatePrayer(state.currentPrayer, s),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.toLocalNum(state.countdown),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${s.next}: ${translatePrayerName(state.nextPrayer, s)} ${s.isArabic ? "في" : "at"} ${s.toLocalNum(state.nextPrayerTime)}',
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

  Widget _buildPrayerTimesRow(
    List<Map<String, dynamic>> prayers,
    AppStrings s,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              s.prayerTimes,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              s.today,
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

  Widget _buildQiblaRamadanRow(BuildContext context, AppStrings s) {
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
                  Text(
                    s.qibla,
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
                  Center(
                    child: Text(
                      s.tapToOpen,
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
          child: GestureDetector(
            onTap: () => context.go('/ramadan'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.ramadanDay,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.comingSoon,
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
        ),
      ],
    );
  }

  Widget _buildVerseCard(
    BuildContext context,
    AppStrings s,
    ReflectionData? reflection,
    bool loading,
  ) {
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
          Row(
            children: [
              const Text(
                '✦',
                style: TextStyle(color: AppColors.gold, fontSize: 16),
              ),
              const SizedBox(width: 10),
              Text(
                s.verseOfDay,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          else if (reflection != null) ...[
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                reflection.arabic,
                style: const TextStyle(
                  fontSize: 22,
                  height: 1.8,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${reflection.translation}"',
              style: const TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: AppColors.onSurface,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              reflection.reference,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
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
                child: Text(
                  s.readReflection,
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
        ],
      ),
    );
  }

  Widget _buildMosqueCard(AppStrings s) {
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.navigation_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    s.nearbyMosques,
                    style: const TextStyle(
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

String translatePrayer(String prayer, AppStrings s) {
  if (prayer == 'Fajr') return s.isArabic ? 'صلاة ${s.fajr}' : 'Fajr Prayer';
  if (prayer == 'Dhuhr') return s.isArabic ? 'صلاة ${s.dhuhr}' : 'Dhuhr Prayer';
  if (prayer == 'Asr') return s.isArabic ? 'صلاة ${s.asr}' : 'Asr Prayer';
  if (prayer == 'Maghrib')
    return s.isArabic ? 'صلاة ${s.maghrib}' : 'Maghrib Prayer';
  if (prayer == 'Isha') return s.isArabic ? 'صلاة ${s.isha}' : 'Isha Prayer';
  return prayer;
}

String translatePrayerName(String name, AppStrings s) {
  if (name == 'Fajr') return s.fajr;
  if (name == 'Dhuhr') return s.dhuhr;
  if (name == 'Asr') return s.asr;
  if (name == 'Maghrib') return s.maghrib;
  if (name == 'Isha') return s.isha;
  return name;
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
