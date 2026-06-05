import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nur_app/features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/qibla/qibla_screen.dart';
import 'features/tasbeeh/tasbeeh_screen.dart';
import 'features/quran/quran_screen.dart';
import 'features/quran/surah_screen.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/ramadan/ramadan_screen.dart';
import 'features/reflection/reflection_screen.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
    GoRoute(path: '/ramadan', builder: (_, __) => const RamadanScreen()),
    GoRoute(path: '/reflection', builder: (_, __) => const ReflectionScreen()),
    GoRoute(
      path: '/surah/:number',
      builder: (_, state) =>
          SurahScreen(number: int.parse(state.pathParameters['number']!)),
    ),

    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/quran', builder: (_, __) => const QuranScreen()),
        GoRoute(path: '/tasbeeh', builder: (_, __) => const TasbeehScreen()),
        GoRoute(path: '/qibla', builder: (_, __) => const QiblaScreen()),
        GoRoute(path: '/more', builder: (_, __) => const SettingsScreen()),
      ],
    ),
  ],
);

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/quran')) return 1;
    if (loc.startsWith('/tasbeeh')) return 2;
    if (loc.startsWith('/qibla')) return 3;
    if (loc.startsWith('/more')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _NurBottomNav(
        selectedIndex: _selectedIndex(context),
      ),
    );
  }
}

class _NurBottomNav extends StatelessWidget {
  final int selectedIndex;
  const _NurBottomNav({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    const items = [
      (icon: Icons.home_rounded, label: 'Home', path: '/home'),
      (icon: Icons.menu_book_rounded, label: 'Quran', path: '/quran'),
      (icon: Icons.fingerprint_rounded, label: 'Tasbeeh', path: '/tasbeeh'),
      (icon: Icons.explore_rounded, label: 'Qibla', path: '/qibla'),
      (icon: Icons.more_horiz_rounded, label: 'More', path: '/more'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = selectedIndex == i;
              return Expanded(
                child: InkWell(
                  onTap: () => context.go(item.path),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: selected
                            ? const Color(0xFFC9A84C)
                            : const Color(0xFF717973),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? const Color(0xFFC9A84C)
                              : const Color(0xFF717973),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
