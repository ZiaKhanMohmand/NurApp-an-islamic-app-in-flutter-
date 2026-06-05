import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';

// Session model
class TasbeehSession {
  final String name;
  final int count;
  final String time;
  TasbeehSession({required this.name, required this.count, required this.time});

  Map<String, dynamic> toJson() => {'name': name, 'count': count, 'time': time};
  factory TasbeehSession.fromJson(Map<String, dynamic> j) =>
      TasbeehSession(name: j['name'], count: j['count'], time: j['time']);
}

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});
  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _dhikrs = [
    {'name': 'SubhanAllah', 'arabic': 'سُبْحَانَ اللّٰه', 'goal': 33},
    {'name': 'Alhamdulillah', 'arabic': 'الحَمْدُ للّٰه', 'goal': 33},
    {'name': 'AllahuAkbar', 'arabic': 'اللّٰهُ أَكْبَر', 'goal': 33},
    {'name': 'Astaghfirullah', 'arabic': 'أَسْتَغْفِرُ اللّٰه', 'goal': 100},
    {'name': 'Custom', 'arabic': '...', 'goal': 99},
  ];

  int _selectedIndex = 0;
  int _count = 0;
  int _goal = 33;
  List<TasbeehSession> _sessions = [];
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnim = _scaleController;
    _loadSessions();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('tasbeeh_sessions') ?? [];
    setState(() {
      _sessions = raw
          .map((e) => TasbeehSession.fromJson(jsonDecode(e)))
          .toList()
          .reversed
          .toList();
    });
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final now = TimeOfDay.now();
    final session = TasbeehSession(
      name: _dhikrs[_selectedIndex]['name'],
      count: _count,
      time:
          '${now.hourOfPeriod.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.period.name.toUpperCase()}',
    );
    final existing = prefs.getStringList('tasbeeh_sessions') ?? [];
    existing.add(jsonEncode(session.toJson()));
    await prefs.setStringList('tasbeeh_sessions', existing);
    await _loadSessions();
  }

  void _tap() {
    HapticFeedback.lightImpact();
    _scaleController.reverse().then((_) => _scaleController.forward());

    setState(() => _count++);

    // Auto save when goal reached
    if (_count == _goal) {
      HapticFeedback.heavyImpact();
      _saveSession();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showGoalDialog();
      });
    }
  }

  void _reset() {
    if (_count > 0) _saveSession();
    setState(() => _count = 0);
  }

  void _selectDhikr(int i) {
    if (_count > 0) _saveSession();
    setState(() {
      _selectedIndex = i;
      _count = 0;
      _goal = _dhikrs[i]['goal'];
    });
  }

  void _setGoal(int g) => setState(() => _goal = g);

  void _showGoalDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Goal of $_goal reached!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'MashaAllah! Keep going.',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _count = 0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _goal > 0 ? (_count / _goal).clamp(0.0, 1.0) : 0.0;

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
                  const Icon(Icons.menu_rounded, color: AppColors.primary),
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
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            // Dhikr selector chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _dhikrs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = _selectedIndex == i;
                  return GestureDetector(
                    onTap: () => _selectDhikr(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                        ),
                      ),
                      child: Text(
                        _dhikrs[i]['name'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Dhikr name
            Text(
              _dhikrs[_selectedIndex]['name'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dhikrs[_selectedIndex]['arabic'],
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Main counter circle
            Stack(
              alignment: Alignment.center,
              children: [
                // Progress ring
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
                // Tap button
                GestureDetector(
                  onTap: _tap,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryContainer,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_count',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Goal: $_goal',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Reset button (left)
                Positioned(
                  left: 0,
                  child: GestureDetector(
                    onTap: _reset,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Goal buttons (right)
                Positioned(
                  right: 0,
                  child: Column(
                    children: [33, 99, 100].map((g) {
                      final active = _goal == g;
                      return GestureDetector(
                        onTap: () => _setGoal(g),
                        child: Container(
                          width: 44,
                          height: 44,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active ? AppColors.gold : AppColors.surface,
                          ),
                          child: Center(
                            child: Text(
                              '$g',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? AppColors.primary
                                    : AppColors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Today's history
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today\'s History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          '${_sessions.length} Sessions',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _sessions.isEmpty
                          ? const Center(
                              child: Text(
                                'No sessions yet today',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _sessions.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) =>
                                  _SessionCard(session: _sessions[i]),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final TasbeehSession session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  session.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${session.count}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
