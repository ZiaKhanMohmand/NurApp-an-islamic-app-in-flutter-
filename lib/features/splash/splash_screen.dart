import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
      body: Stack(
        children: [
          // Islamic geometric pattern background
          Positioned.fill(child: _GeometricPattern()),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Crescent moon icon
                    _CrescentMoon(),
                    const SizedBox(height: 32),
                    // Nur logo box
                    _NurLogo(),
                    const SizedBox(height: 24),
                    // Tagline
                    const Text(
                      'SACRED TRANQUILITY',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom text
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: const Column(
                children: [
                  // Dot indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_Dot(active: true)],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'SINCE 1445 AH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w500,
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

// Crescent moon drawn with CustomPaint
class _CrescentMoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(painter: _CrescentPainter()),
    );
  }
}

class _CrescentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.gold;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    // Crescent
    final path = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    final cutPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(cx + r * 0.45, cy - r * 0.1),
          radius: r * 0.82,
        ),
      );
    final crescent = Path.combine(PathOperation.difference, path, cutPath);
    canvas.drawPath(crescent, paint);

    // Star
    _drawStar(canvas, paint, cx + r * 0.85, cy - r * 0.65, 7);
  }

  void _drawStar(Canvas canvas, Paint paint, double cx, double cy, double r) {
    final p2 = Path();
    final pts = [
      Offset(cx, cy - r),
      Offset(cx + r * 0.3, cy - r * 0.3),
      Offset(cx + r, cy),
      Offset(cx + r * 0.3, cy + r * 0.3),
      Offset(cx, cy + r),
      Offset(cx - r * 0.3, cy + r * 0.3),
      Offset(cx - r, cy),
      Offset(cx - r * 0.3, cy - r * 0.3),
    ];
    p2.moveTo(pts[0].dx, pts[0].dy);
    for (final pt in pts.skip(1)) {
      p2.lineTo(pt.dx, pt.dy);
    }
    p2.close();
    canvas.drawPath(p2, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// Nur logo box
class _NurLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'نور',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'NUR',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}

// Geometric background pattern
class _GeometricPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PatternPainter());
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const spacing = 60.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        _drawCross(canvas, paint, x + spacing / 2, y + spacing / 2, 10);
      }
    }
  }

  void _drawCross(Canvas c, Paint p, double x, double y, double r) {
    c.drawLine(Offset(x, y - r), Offset(x, y + r), p);
    c.drawLine(Offset(x - r, y), Offset(x + r, y), p);
    c.drawLine(
      Offset(x - r * 0.7, y - r * 0.7),
      Offset(x + r * 0.7, y + r * 0.7),
      p,
    );
    c.drawLine(
      Offset(x + r * 0.7, y - r * 0.7),
      Offset(x - r * 0.7, y + r * 0.7),
      p,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 8 : 6,
      height: active ? 8 : 6,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.gold : AppColors.gold.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}
