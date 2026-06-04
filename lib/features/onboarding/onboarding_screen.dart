import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Sacred Presence',
      subtitle:
          'Enable location to receive precise prayer times and qibla direction based on your current journey.',
      buttonLabel: 'Enable Location',
      buttonIcon: Icons.navigation_rounded,
      isLocationPage: true,
    ),
    _OnboardingData(
      title: 'Never Miss a Prayer',
      subtitle:
          'Receive gentle reminders for each prayer time with customizable Adhan notifications.',
      buttonLabel: 'Enable Notifications',
      buttonIcon: Icons.notifications_rounded,
      isLocationPage: false,
    ),
    _OnboardingData(
      title: 'Begin Your Journey',
      subtitle:
          'Your companion for daily prayers, Quran reading, and spiritual reflection. May Allah guide your path.',
      buttonLabel: 'Get Started',
      buttonIcon: Icons.arrow_forward_rounded,
      isLocationPage: false,
    ),
  ];

  Future<void> _handleButton() async {
    if (_currentPage == 0) {
      await Permission.location.request();
    } else if (_currentPage == 1) {
      await Permission.notification.request();
    }

    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Geometric pattern
          Positioned.fill(child: _OnboardingPattern()),

          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                child: Column(
                  children: [
                    // Gold button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _handleButton,
                        icon: Icon(
                          _pages[_currentPage].buttonIcon,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          _pages[_currentPage].buttonLabel,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dots + Skip row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            _pages.length,
                            (i) => _OnboardingDot(active: i == _currentPage),
                          ),
                        ),
                        if (_currentPage < _pages.length - 1)
                          TextButton(
                            onPressed: () => context.go('/home'),
                            child: const Text(
                              'SKIP',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Column(
        children: [
          // Mosque image placeholder (green gradient card)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A2A1A), AppColors.primaryContainer],
                ),
              ),
              child: const Center(
                child: Text('🕌', style: TextStyle(fontSize: 80)),
              ),
            ),
          ),
          const SizedBox(height: 36),

          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String title, subtitle, buttonLabel;
  final IconData buttonIcon;
  final bool isLocationPage;
  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.isLocationPage,
  });
}

class _OnboardingDot extends StatelessWidget {
  final bool active;
  const _OnboardingDot({required this.active});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 20 : 8,
      height: 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.gold : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _OnboardingPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PatternPainter2());
  }
}

class _PatternPainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const spacing = 70.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawLine(Offset(x, y - 12), Offset(x, y + 12), paint);
        canvas.drawLine(Offset(x - 12, y), Offset(x + 12, y), paint);
        canvas.drawLine(Offset(x - 8, y - 8), Offset(x + 8, y + 8), paint);
        canvas.drawLine(Offset(x + 8, y - 8), Offset(x - 8, y + 8), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
