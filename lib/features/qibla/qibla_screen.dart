import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nur_app/core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});
  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen>
    with TickerProviderStateMixin {
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  double? _compassHeading;
  double _qiblaAngle = 0;
  double _distanceKm = 0;
  String _city = 'Locating...';
  bool _hasPermission = false;
  bool _aligned = false;

  final List<double> _headingBuffer = [];
  static const int _bufferSize = 5;

  AnimationController? _pulseController;
  AnimationController? _glowController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _init();
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    _glowController?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      final angle = _calculateQibla(pos.latitude, pos.longitude);
      final dist = _calculateDistance(
        pos.latitude,
        pos.longitude,
        _kaabaLat,
        _kaabaLng,
      );

      setState(() {
        _qiblaAngle = angle;
        _distanceKm = dist;
        _city =
            '${pos.latitude.toStringAsFixed(4)}°N, ${pos.longitude.toStringAsFixed(4)}°E';
        _hasPermission = true;
      });

      FlutterCompass.events?.listen((event) {
        if (!mounted || event.heading == null) return;

        _headingBuffer.add(event.heading!);
        if (_headingBuffer.length > _bufferSize) _headingBuffer.removeAt(0);
        final smoothed = _circularMean(_headingBuffer);

        final diff = ((_qiblaAngle - smoothed) % 360 + 360) % 360;
        final isAligned = diff < 10 || diff > 350;

        if (isAligned && !_aligned) _glowController?.forward(from: 0);

        setState(() {
          _compassHeading = smoothed;
          _aligned = isAligned;
        });
      });
    } catch (e) {
      setState(() {
        _hasPermission = false;
        _city = ref.read(stringsProvider).isArabic
            ? 'يرجى تمكين خدمات الموقع'
            : 'Please enable location services';
      });
    }
  }

  double _circularMean(List<double> angles) {
    double sinSum = 0, cosSum = 0;
    for (final a in angles) {
      sinSum += math.sin(a * math.pi / 180);
      cosSum += math.cos(a * math.pi / 180);
    }
    return (math.atan2(sinSum, cosSum) * 180 / math.pi + 360) % 360;
  }

  double _calculateQibla(double lat, double lng) {
    final dLng = (_kaabaLng - lng) * math.pi / 180;
    final lat1 = lat * math.pi / 180;
    final lat2 = _kaabaLat * math.pi / 180;
    final y = math.sin(dLng) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  String _getDirectionHint() {
    if (_compassHeading == null) return 'CALIBRATING...';
    final diff = ((_qiblaAngle - _compassHeading!) % 360 + 360) % 360;
    if (diff < 10 || diff > 350) return '✦  FACING QIBLA';
    if (diff < 180) return 'TURN RIGHT ▶  ${diff.toStringAsFixed(0)}°';
    return 'TURN LEFT ◀  ${(360 - diff).toStringAsFixed(0)}°';
  }

  String _getCardinalDirection() {
    // Cardinal direction of Qibla from user's location
    final a = _qiblaAngle;
    if (a >= 337.5 || a < 22.5) return 'NORTH';
    if (a < 67.5) return 'NORTH-EAST';
    if (a < 112.5) return 'EAST';
    if (a < 157.5) return 'SOUTH-EAST';
    if (a < 202.5) return 'SOUTH';
    if (a < 247.5) return 'SOUTH-WEST';
    if (a < 292.5) return 'WEST';
    return 'NORTH-WEST';
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);

    double markerTurns = 0;
    if (_compassHeading != null) {
      markerTurns = (_qiblaAngle - _compassHeading!) / 360.0;
    } else {
      markerTurns = _qiblaAngle / 360.0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF010D07),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _StarFieldPainter())),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'NurApp',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Direction hint badge
                _buildStatusBadge(),

                const SizedBox(height: 8),

                // Qibla direction label
                Text(
                  'QIBLA DIRECTION: ${_getCardinalDirection()}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _pulseController ?? const AlwaysStoppedAnimation(0),
                        _glowController ?? const AlwaysStoppedAnimation(0),
                      ]),
                      builder: (_, __) => _buildCompass(markerTurns),
                    ),
                  ),
                ),

                _buildInfoPanel(strings),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _aligned
              ? AppColors.gold.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseController ?? const AlwaysStoppedAnimation(0),
            builder: (_, __) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _aligned
                    ? AppColors.gold
                    : _hasPermission
                    ? Colors.greenAccent
                    : Colors.orange,
                boxShadow: [
                  BoxShadow(
                    color: (_aligned ? AppColors.gold : Colors.greenAccent)
                        .withValues(
                          alpha: (_pulseController?.value ?? 0) * 0.8,
                        ),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _hasPermission ? _getDirectionHint() : 'PERMISSION NEEDED',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _aligned ? AppColors.gold : Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass(double markerTurns) {
    final glowOpacity = _aligned
        ? (0.3 + (_glowController?.value ?? 0) * 0.4)
        : 0.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (_aligned)
          Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: glowOpacity),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),

        CustomPaint(
          size: const Size(310, 310),
          painter: _GeometricRingPainter(),
        ),

        // Compass face — STATIC
        CustomPaint(size: const Size(260, 260), painter: _CompassFacePainter()),

        // Kaaba marker — rotates to point at Qibla
        AnimatedRotation(
          turns: markerTurns,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: SizedBox(
            width: 260,
            height: 260,
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _aligned
                          ? AppColors.gold
                          : AppColors.gold.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: _aligned
                          ? [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.6),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: const Text('🕋', style: TextStyle(fontSize: 14)),
                  ),
                  Container(
                    width: 2,
                    height: 20,
                    color: _aligned
                        ? AppColors.gold
                        : AppColors.gold.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Center jewel
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.star, color: Colors.white, size: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPanel(AppStrings strings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _InfoItem(
                label: strings.isArabic
                    ? 'المسافة إلى مكة'
                    : 'DISTANCE TO MAKKAH',
                value: '${_distanceKm.toStringAsFixed(0)} km',
                icon: Icons.social_distance_rounded,
              ),
            ),
            Container(width: 1, height: 40, color: Colors.white12),
            Expanded(
              child: _InfoItem(
                label: strings.isArabic ? 'زاوية القبلة' : 'QIBLA ANGLE',
                value: '${_qiblaAngle.toStringAsFixed(1)}°',
                icon: Icons.explore_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.gold, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _CompassFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = const Color(0xFF0A1F14)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF1A3A24), const Color(0xFF050F08)],
        ).createShader(Rect.fromCircle(center: center, radius: r))
        ..style = PaintingStyle.fill,
    );

    final tickPaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final isMajor = i % 90 == 0;
      final isMedium = i % 45 == 0;
      final tickLen = isMajor
          ? 16.0
          : isMedium
          ? 10.0
          : 6.0;
      tickPaint.color = isMajor
          ? AppColors.gold
          : isMedium
          ? Colors.white54
          : Colors.white24;
      tickPaint.strokeWidth = isMajor ? 2 : 1;
      canvas.drawLine(
        Offset(
          center.dx + (r - tickLen) * math.sin(angle),
          center.dy - (r - tickLen) * math.cos(angle),
        ),
        Offset(
          center.dx + r * math.sin(angle),
          center.dy - r * math.cos(angle),
        ),
        tickPaint,
      );
    }

    final dirs = {'N': 0.0, 'E': 90.0, 'S': 180.0, 'W': 270.0};
    for (final entry in dirs.entries) {
      final angle = entry.value * math.pi / 180;
      final labelR = r - 28.0;
      final x = center.dx + labelR * math.sin(angle);
      final y = center.dy - labelR * math.cos(angle);
      final isNorth = entry.key == 'N';
      final tp = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: TextStyle(
            fontSize: isNorth ? 18 : 14,
            fontWeight: FontWeight.w800,
            color: isNorth ? AppColors.gold : Colors.white70,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }

    canvas.drawCircle(
      center,
      r - 2,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GeometricRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.15)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      center,
      r - 8,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.08)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    final starPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(
          center.dx + (r - 4) * math.cos(angle),
          center.dy + (r - 4) * math.sin(angle),
        ),
        Offset(
          center.dx + (r - 20) * math.cos(angle),
          center.dy + (r - 20) * math.sin(angle),
        ),
        starPaint,
      );
    }

    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 - math.pi / 2;
      final cx = center.dx + (r + 4) * math.cos(angle);
      final cy = center.dy + (r + 4) * math.sin(angle);
      final path = Path()
        ..moveTo(cx, cy - 6)
        ..lineTo(cx + 4, cy)
        ..lineTo(cx, cy + 6)
        ..lineTo(cx - 4, cy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.gold.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.5;
      paint.color = Colors.white.withValues(
        alpha: 0.1 + rng.nextDouble() * 0.3,
      );
      canvas.drawCircle(Offset(x, y), r, paint);
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF012D1D).withValues(alpha: 0.6),
            const Color(0xFF010D07),
          ],
          radius: 0.8,
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
