import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/theme/app_colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late HijriCalendar _currentHijri;
  late DateTime _currentGreg;
  int _hijriMonth = 0;
  int _hijriYear = 0;

  final List<Map<String, dynamic>> _islamicEvents = [
    {
      'hijriMonth': 1,
      'hijriDay': 10,
      'name': 'Day of Ashura',
      'monthAbbr': 'MUH',
    },
    {
      'hijriMonth': 3,
      'hijriDay': 12,
      'name': 'Mawlid Al-Nabi',
      'monthAbbr': 'RAB',
    },
    {
      'hijriMonth': 7,
      'hijriDay': 27,
      'name': 'Isra\' Wal Mi\'raj',
      'monthAbbr': 'RAJ',
    },
    {
      'hijriMonth': 8,
      'hijriDay': 15,
      'name': 'Mid Sha\'ban',
      'monthAbbr': 'SHA',
    },
    {
      'hijriMonth': 9,
      'hijriDay': 1,
      'name': 'Ramadan Begins',
      'monthAbbr': 'RAM',
    },
    {
      'hijriMonth': 10,
      'hijriDay': 1,
      'name': 'Eid Al-Fitr',
      'monthAbbr': 'SHW',
    },
    {
      'hijriMonth': 12,
      'hijriDay': 10,
      'name': 'Eid Al-Adha',
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

  String _hijriMonthName(int m) => [
    'Muharram',
    'Safar',
    'Rabi Al-Awwal',
    'Rabi Al-Thani',
    'Jumada Al-Awwal',
    'Jumada Al-Thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhul Qa\'dah',
    'Dhul Hijjah',
  ][m - 1];

  // Get days in hijri month
  int _daysInHijriMonth(int month, int year) {
    // Hijri months alternate 30/29 days
    return month % 2 == 1 ? 30 : 29;
  }

  // Get weekday of 1st of hijri month
  int _firstWeekday(int month, int year) {
    final greg = HijriCalendar()
      ..hYear = year
      ..hMonth = month
      ..hDay = 1;
    return greg.hijriToGregorian(year, month, 1).weekday % 7;
  }

  @override
  Widget build(BuildContext context) {
    final today = HijriCalendar.fromDate(DateTime.now());
    final daysInMonth = _daysInHijriMonth(_hijriMonth, _hijriYear);
    final firstDay = _firstWeekday(_hijriMonth, _hijriYear);
    final upcomingEvents = _islamicEvents
        .where((e) => e['hijriMonth'] >= _hijriMonth)
        .take(3)
        .toList();

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
                  const Expanded(
                    child: Text(
                      'Hijri Calendar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
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
                              _hijriMonthName(_hijriMonth),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '$_hijriYear AH',
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
                              children:
                                  [
                                        'SUN',
                                        'MON',
                                        'TUE',
                                        'WED',
                                        'THU',
                                        'FRI',
                                        'SAT',
                                      ]
                                      .map(
                                        (d) => Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            child: Text(
                                              d,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.gold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
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

                                // Get gregorian date
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
                                        ? AppColors.goldLight.withOpacity(0.3)
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
                                        '$dayNum',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isToday
                                              ? Colors.white
                                              : AppColors.onSurface,
                                        ),
                                      ),
                                      Text(
                                        '${gregDate.day} ${_shortMonth(gregDate.month)}',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: isToday
                                              ? Colors.white.withOpacity(0.8)
                                              : AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      if (isEvent)
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.gold,
                                          ),
                                        ),
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

                    // Upcoming events
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          _hijriMonthName(_hijriMonth).toUpperCase(),
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

                    ..._islamicEvents.map(
                      (e) => _EventCard(event: e, hijriYear: _hijriYear),
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

  String _shortMonth(int m) => [
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
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final int hijriYear;
  const _EventCard({required this.event, required this.hijriYear});

  @override
  Widget build(BuildContext context) {
    // Convert to gregorian
    final greg = HijriCalendar()
      ..hYear = hijriYear
      ..hMonth = event['hijriMonth']
      ..hDay = event['hijriDay'];
    final gregDate = greg.hijriToGregorian(
      hijriYear,
      event['hijriMonth'],
      event['hijriDay'],
    );

    final months = [
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
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
                  '${event['hijriDay']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  event['monthAbbr'],
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
                  event['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${weekdays[gregDate.weekday - 1]}, ${gregDate.day} ${months[gregDate.month - 1]} ${gregDate.year}',
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
