import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nur_app/core/l10n/app_strings.dart';

class AsmaUlHusnaScreen extends ConsumerStatefulWidget {
  const AsmaUlHusnaScreen({super.key});

  @override
  ConsumerState<AsmaUlHusnaScreen> createState() => _AsmaUlHusnaScreenState();
}

class _AsmaUlHusnaScreenState extends ConsumerState<AsmaUlHusnaScreen> {
  List<Map<String, dynamic>> _names = [];
  List<Map<String, dynamic>> _filtered = [];
  final _searchController = TextEditingController();
  bool _loading = true;

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _audioLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  static const _gold = Color(0xFFC9A84C);
  static const _audioUrl =
      'https://www.quranclick.com/Downloads/Duain/Allah-names.mp3';

  @override
  void initState() {
    super.initState();
    _loadNames();
    _searchController.addListener(_onSearch);

    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        _audioLoading =
            state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
      });
    });

    _player.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });

    _player.durationStream.listen((dur) {
      if (!mounted) return;
      setState(() => _duration = dur ?? Duration.zero);
    });
  }

  Future<void> _loadNames() async {
    final raw = await rootBundle.loadString('lib/core/data/asma_ul_husna.json');
    final data = List<Map<String, dynamic>>.from(jsonDecode(raw));
    setState(() {
      _names = data;
      _filtered = data;
      _loading = false;
    });
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _names
          : _names.where((n) {
              return n['transliteration'].toString().toLowerCase().contains(
                    q,
                  ) ||
                  n['meaning'].toString().toLowerCase().contains(q) ||
                  n['arabic'].toString().contains(q);
            }).toList();
    });
  }

  Future<void> _toggleAudio() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        if (_player.processingState == ProcessingState.idle) {
          await _player.setUrl(_audioUrl);
        }
        await _player.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load audio. Check internet connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _seek(double value) async {
    final pos = Duration(milliseconds: value.toInt());
    await _player.seek(pos);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _player.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final isArabic = s.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0E1412) : const Color(0xFFF8F5EF);
    final cardBg = isDark ? const Color(0xFF1A211C) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark
        ? const Color(0xFF8A9E93)
        : const Color(0xFF717973);

    final showPlayer =
        _isPlaying ||
        _audioLoading ||
        _player.processingState == ProcessingState.ready;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _gold),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/more');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              s.asmaUlHusna,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 25,
                color: _gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              s.namesOfAllah,
              style: TextStyle(
                fontSize: 11,
                color: textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),

      // Mini Player at bottom
      bottomNavigationBar: _MiniPlayer(
        isPlaying: _isPlaying,
        isLoading: _audioLoading,
        position: _position,
        duration: _duration,
        onToggle: _toggleAudio,
        onSeek: _seek,
        formatDuration: _formatDuration,
        isDark: isDark,
        isArabic: isArabic,
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : CustomScrollView(
              slivers: [
                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _gold.withValues(alpha: 0.2)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: s.searchAsma,
                          hintStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: textSecondary,
                            size: 18,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Count label
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      '${_filtered.length} ${s.namesCount}',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ),
                ),

                // Grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _NameCard(
                        name: _filtered[i],
                        cardBg: cardBg,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        isArabic: isArabic,
                        s: s,
                      ),
                      childCount: _filtered.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Mini Player Widget ──────────────────────────────────────────────────────

class _MiniPlayer extends StatelessWidget {
  final bool isPlaying, isLoading, isDark, isArabic;
  final Duration position, duration;
  final VoidCallback onToggle;
  final ValueChanged<double> onSeek;
  final String Function(Duration) formatDuration;

  const _MiniPlayer({
    required this.isPlaying,
    required this.isLoading,
    required this.position,
    required this.duration,
    required this.onToggle,
    required this.onSeek,
    required this.formatDuration,
    required this.isDark,
    required this.isArabic,
  });

  static const _gold = Color(0xFFC9A84C);

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A211C) : Colors.white;
    final textSecondary = isDark
        ? const Color(0xFF8A9E93)
        : const Color(0xFF717973);
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(color: _gold.withValues(alpha: 0.2), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label + controls row
              Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '٩٩',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'أسماء الله الحسنى' : 'Asma ul Husna',
                          style: TextStyle(
                            fontFamily: isArabic ? 'Amiri' : null,
                            fontSize: isArabic ? 15 : 13,
                            fontWeight: FontWeight.w700,
                            color: _gold,
                          ),
                        ),
                        Text(
                          isArabic ? 'تلاوة كاملة' : 'Full Recitation',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ),
                  ),

                  // Play/Pause button
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress bar
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: _gold,
                      inactiveTrackColor: _gold.withValues(alpha: 0.15),
                      thumbColor: _gold,
                      overlayColor: _gold.withValues(alpha: 0.15),
                    ),
                    child: Slider(
                      value: position.inMilliseconds.toDouble().clamp(
                        0,
                        duration.inMilliseconds.toDouble(),
                      ),
                      min: 0,
                      max: duration.inMilliseconds > 0
                          ? duration.inMilliseconds.toDouble()
                          : 1,
                      onChanged: onSeek,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDuration(position),
                          style: TextStyle(fontSize: 10, color: textSecondary),
                        ),
                        Text(
                          formatDuration(duration),
                          style: TextStyle(fontSize: 10, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Name Card ───────────────────────────────────────────────────────────────

class _NameCard extends StatelessWidget {
  final Map<String, dynamic> name;
  final Color cardBg, textPrimary, textSecondary;
  final bool isArabic;
  final AppStrings s;

  const _NameCard({
    required this.name,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.isArabic,
    required this.s,
  });

  static const _gold = Color(0xFFC9A84C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _gold.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                s.toLocalNum('${name['number']}'),
                style: const TextStyle(
                  color: _gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                name['arabic'],
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  color: _gold,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name['transliteration'],
              style: TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              name['meaning'],
              style: TextStyle(color: textSecondary, fontSize: 11, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A211C) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark
        ? const Color(0xFF8A9E93)
        : const Color(0xFF717973);

    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${s.toLocalNum('${name['number']}')} ${s.ofNinetyNine}',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              name['arabic'],
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 48,
                color: _gold,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: _gold.withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            Text(
              name['transliteration'],
              style: TextStyle(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name['meaning'],
              style: TextStyle(color: textSecondary, fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
