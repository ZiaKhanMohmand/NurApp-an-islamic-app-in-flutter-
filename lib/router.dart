import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'core/l10n/app_strings.dart';
import 'features/asma_ul_husna/asma_ul_husna_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/calendar', builder: (_, _) => const CalendarScreen()),
    GoRoute(path: '/ramadan', builder: (_, _) => const RamadanScreen()),
    GoRoute(path: '/reflection', builder: (_, _) => const ReflectionScreen()),
    GoRoute(path: '/asma', builder: (_, _) => const AsmaUlHusnaScreen()),
    GoRoute(
      path: '/surah/:number',
      builder: (_, state) =>
          SurahScreen(number: int.parse(state.pathParameters['number']!)),
    ),

    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/quran', builder: (_, _) => const QuranScreen()),
        GoRoute(path: '/tasbeeh', builder: (_, _) => const TasbeehScreen()),
        GoRoute(path: '/qibla', builder: (_, _) => const QiblaScreen()),
        GoRoute(path: '/more', builder: (_, _) => const SettingsScreen()),
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

class _NurBottomNav extends ConsumerWidget {
  final int selectedIndex;
  const _NurBottomNav({required this.selectedIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    final items = [
      (icon: Icons.home_rounded, label: s.home, path: '/home'),
      (icon: Icons.menu_book_rounded, label: s.quran, path: '/quran'),
      (icon: Icons.fingerprint_rounded, label: s.tasbeeh, path: '/tasbeeh'),
      (icon: Icons.explore_rounded, label: s.qibla, path: '/qibla'),
      (icon: Icons.more_horiz_rounded, label: s.more, path: '/more'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.15), width: 1),
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
