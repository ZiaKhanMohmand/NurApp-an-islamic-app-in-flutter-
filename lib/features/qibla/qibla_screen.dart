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

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  // Kaaba coordinates
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  double? _compassHeading;
  double _qiblaAngle = 0;
  double _distanceKm = 0;
  String _city = 'Locating...';
  bool _hasPermission = false;

  @override
  void initState() {
    _hasPermission = true;
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
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
            '${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)}';
        _hasPermission = true;
      });

      // Start compass stream
      FlutterCompass.events?.listen((event) {
        if (mounted && event.heading != null) {
          setState(() => _compassHeading = event.heading);
        }
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

  // Haversine formula for qibla direction
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

  // Distance in km
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

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final accuracy = _hasPermission
        ? strings.highAccuracy
        : strings.isArabic
        ? 'إذن مطلوب'
        : 'PERMISSION NEEDED';

    // Needle rotation = qibla angle - compass heading
    final needleAngle = _compassHeading != null
        ? (_qiblaAngle - _compassHeading!) * math.pi / 180
        : _qiblaAngle * math.pi / 180;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(child: CustomPaint(painter: _QiblaPatternPainter())),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
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
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Accuracy badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _hasPermission ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        accuracy,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Compass
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring
                          CustomPaint(
                            size: const Size(280, 280),
                            painter: _CompassRingPainter(),
                          ),
                          // Compass face
                          Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          // N S E W labels
                          ..._buildDirectionLabels(),
                          // Animated needle
                          AnimatedRotation(
                            turns: needleAngle / (2 * math.pi),
                            duration: const Duration(milliseconds: 300),
                            child: CustomPaint(
                              size: const Size(200, 200),
                              painter: _NeedlePainter(),
                            ),
                          ),
                          // Center dot
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Distance
                Text(
                  strings.distanceToMakkah,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: strings.toLocalNum(
                          _distanceKm.toStringAsFixed(0),
                        ),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(
                        text: strings.isArabic ? ' كم' : ' km',
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Location card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          color: AppColors.gold,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _city,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${strings.qiblaAngle}: ${strings.toLocalNum(_qiblaAngle.toStringAsFixed(1))}°',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDirectionLabels() {
    const labels = {
      'N': Offset(0, -100),
      'S': Offset(0, 100),
      'E': Offset(100, 0),
      'W': Offset(-100, 0),
    };
    return labels.entries
        .map(
          (e) => Positioned(
            left: 140 + e.value.dx - 8,
            top: 140 + e.value.dy - 10,
            child: Text(
              e.key,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        )
        .toList();
  }
}

// Compass outer ring
class _CompassRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;

    // Dashed ring
    final paint = Paint()
      ..color = AppColors.surfaceVariant
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashCount = 60;
    for (int i = 0; i < dashCount; i++) {
      final angle = (i * 360 / dashCount) * math.pi / 180;
      if (i % 2 == 0) {
        canvas.drawLine(
          Offset(
            center.dx + (r - 6) * math.cos(angle),
            center.dy + (r - 6) * math.sin(angle),
          ),
          Offset(
            center.dx + r * math.cos(angle),
            center.dy + r * math.sin(angle),
          ),
          paint,
        );
      }
    }

    // Gold accent ring
    final goldPaint = Paint()
      ..color = AppColors.gold.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, r - 10, goldPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// Needle pointing to Qibla
class _NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Gold needle (points to Qibla)
    final needlePaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.gold, AppColors.gold.withOpacity(0.3)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - 60, center.dy),
      Offset(center.dx + 80, center.dy),
      needlePaint,
    );

    // Dot on needle
    canvas.drawCircle(
      Offset(center.dx - 55, center.dy),
      5,
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// Background pattern
class _QiblaPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.04)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const r = 35.0;
    const spacing = 70.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
