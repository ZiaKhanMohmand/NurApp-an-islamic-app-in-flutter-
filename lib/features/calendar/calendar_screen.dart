import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:nur_app/core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late HijriCalendar _currentHijri;
  late DateTime _currentGreg;
  int _hijriMonth = 0;
  int _hijriYear = 0;

  // Key tracking references to translated string getters
  final List<Map<String, dynamic>> _islamicEvents = [
    {
      'hijriMonth': 1,
      'hijriDay': 10,
      'stringKey': 'dayOfAshura',
      'monthAbbr': 'MUH',
    },
    {
      'hijriMonth': 3,
      'hijriDay': 12,
      'stringKey': 'mawlidAlNabi',
      'monthAbbr': 'RAB',
    },
    {
      'hijriMonth': 7,
      'hijriDay': 27,
      'stringKey': 'israWalMiraj',
      'monthAbbr': 'RAJ',
    },
    {
      'hijriMonth': 8,
      'hijriDay': 15,
      'stringKey': 'midShaban',
      'monthAbbr': 'SHA',
    },
    {
      'hijriMonth': 9,
      'hijriDay': 1,
      'stringKey': 'ramadanBegins',
      'monthAbbr': 'RAM',
    },
    {
      'hijriMonth': 10,
      'hijriDay': 1,
      'stringKey': 'eidAlFitr',
      'monthAbbr': 'SHW',
    },
    {
      'hijriMonth': 12,
      'hijriDay': 10,
      'stringKey': 'eidAlAdha',
      'monthAbbr': 'DHU',
    },
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentGreg = now;
    _currentHijri = HijriCalendar.fromDate(now);
    _hijriMonth = _currentHijri.hMonth;
    _hijriYear = _currentHijri.hYear;
  }

  void _prevMonth() => setState(() {
    _hijriMonth--;
    if (_hijriMonth < 1) {
      _hijriMonth = 12;
      _hijriYear--;
    }
  });

  void _nextMonth() => setState(() {
    _hijriMonth++;
    if (_hijriMonth > 12) {
      _hijriMonth = 1;
      _hijriYear++;
    }
  });

  String _getHijriMonthName(AppStrings s, int m) {
    return [
      s.muharram,
      s.safar,
      s.rabiAlAwwal,
      s.rabiAlThani,
      s.jumadaAlAwwal,
      s.jumadaAlThani,
      s.rajab,
      s.shaban,
      s.ramadan,
      s.shawwal,
      s.dhulQadah,
      s.dhulHijjah,
    ][m - 1];
  }

  int _daysInHijriMonth(int month, int year) {
    return month % 2 == 1 ? 30 : 29;
  }

  int _firstWeekday(int month, int year) {
    final greg = HijriCalendar()
      ..hYear = year
      ..hMonth = month
      ..hDay = 1;
    return greg.hijriToGregorian(year, month, 1).weekday % 7;
  }

  String _getEventName(AppStrings s, String key) {
    switch (key) {
      case 'dayOfAshura':
        return s.dayOfAshura;
      case 'mawlidAlNabi':
        return s.mawlidAlNabi;
      case 'israWalMiraj':
        return s.israWalMiraj;
      case 'midShaban':
        return s.midShaban;
      case 'ramadanBegins':
        return s.ramadanBegins;
      case 'eidAlFitr':
        return s.eidAlFitr;
      case 'eidAlAdha':
        return s.eidAlAdha;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final today = HijriCalendar.fromDate(DateTime.now());
    final daysInMonth = _daysInHijriMonth(_hijriMonth, _hijriYear);
    final firstDay = _firstWeekday(_hijriMonth, _hijriYear);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: () => context.go('/home'),
                  ),
                  Expanded(
                    child: Text(
                      s.hijriCalendar,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Month navigator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _prevMonth,
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              _getHijriMonthName(s, _hijriMonth),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${s.toLocalNum(_hijriYear.toString())} ${s.isArabic ? 'هـ' : 'AH'}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _nextMonth,
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Calendar grid
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: Column(
                        children: [
                          // Day headers
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: List.generate(7, (index) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      s.shortWeekday(index),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          // Grid cells
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    childAspectRatio: 0.85,
                                  ),
                              itemCount: 42,
                              itemBuilder: (_, i) {
                                final dayNum = i - firstDay + 1;
                                if (dayNum < 1 || dayNum > daysInMonth) {
                                  return const SizedBox();
                                }

                                final isToday =
                                    today.hDay == dayNum &&
                                    today.hMonth == _hijriMonth &&
                                    today.hYear == _hijriYear;

                                final isEvent = _islamicEvents.any(
                                  (e) =>
                                      e['hijriMonth'] == _hijriMonth &&
                                      e['hijriDay'] == dayNum,
                                );

                                final greg = HijriCalendar()
                                  ..hYear = _hijriYear
                                  ..hMonth = _hijriMonth
                                  ..hDay = dayNum;
                                final gregDate = greg.hijriToGregorian(
                                  _hijriYear,
                                  _hijriMonth,
                                  dayNum,
                                );

                                return Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? AppColors.primaryContainer
                                        : isEvent
                                        ? AppColors.goldLight.withValues(
                                            alpha: 0.3,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isToday
                                        ? Border.all(
                                            color: AppColors.gold,
                                            width: 1.5,
                                          )
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        s.toLocalNum(dayNum.toString()),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isToday
                                              ? Colors.white
                                              : AppColors.onSurface,
                                        ),
                                      ),
                                      Text(
                                        '${s.toLocalNum(gregDate.day.toString())} ${s.shortMonth(gregDate.month)}',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: isToday
                                              ? Colors.white.withValues(
                                                  alpha: 0.8,
                                                )
                                              : AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      if (isEvent) ...[
                                        const SizedBox(height: 2),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.gold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Upcoming events header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.upcomingEvents,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          _getHijriMonthName(s, _hijriMonth).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Event card mapping list
                    ..._islamicEvents.map(
                      (e) => _EventCard(
                        event: e,
                        hijriYear: _hijriYear,
                        eventName: _getEventName(s, e['stringKey']),
                        shortMonthText: s.shortMonth(
                          HijriCalendar()
                              .hijriToGregorian(
                                _hijriYear,
                                e['hijriMonth'],
                                e['hijriDay'],
                              )
                              .month,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends ConsumerWidget {
  final Map<String, dynamic> event;
  final int hijriYear;
  final String eventName;
  final String shortMonthText;

  const _EventCard({
    required this.event,
    required this.hijriYear,
    required this.eventName,
    required this.shortMonthText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    final greg = HijriCalendar()
      ..hYear = hijriYear
      ..hMonth = event['hijriMonth']
      ..hDay = event['hijriDay'];
    final gregDate = greg.hijriToGregorian(
      hijriYear,
      event['hijriMonth'],
      event['hijriDay'],
    );

    final weekdaysAr = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekdayText = s.isArabic
        ? weekdaysAr[gregDate.weekday - 1]
        : weekdaysEn[gregDate.weekday - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          // Date badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  s.toLocalNum(event['hijriDay'].toString()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  event['monthAbbr'], // Keeps standard system abbreviation code
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.isArabic
                      ? '$weekdayText، ${s.toLocalNum(gregDate.day.toString())} $shortMonthText ${s.toLocalNum(gregDate.year.toString())}'
                      : '$weekdayText, ${gregDate.day} $shortMonthText ${gregDate.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }
}
