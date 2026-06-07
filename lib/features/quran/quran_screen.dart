import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nur_app/core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import 'quran_service.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});
  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  List<Surah> _surahs = [];
  List<Surah> _filtered = [];
  Map<String, dynamic>? _lastRead;
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final surahs = await QuranService.fetchSurahs();
    final lastRead = await QuranService.getLastRead();

    if (!mounted) return;

    setState(() {
      _surahs = surahs;
      _filtered = surahs;
      _lastRead = lastRead;
      _loading = false;
    });
  }

  void _search(String q) {
    setState(() {
      _filtered = _surahs
          .where(
            (s) =>
                s.englishName.toLowerCase().contains(q.toLowerCase()) ||
                s.name.contains(q) ||
                s.number.toString() == q,
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
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

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: s.searchSurah,
                  hintStyle: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Last read card
                    if (_lastRead != null) ...[
                      _LastReadCard(
                        data: _lastRead!,
                        surah: _surahs.firstWhere(
                          (s) => s.number == _lastRead!['surah'],
                        ),
                        onTap: () =>
                            context.go('/surah/${_lastRead!['surah']}'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tab label
                    Text(
                      s.surahs,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(height: 2, width: 40, color: AppColors.gold),
                    const SizedBox(height: 12),

                    // Surah list
                    ..._filtered.map(
                      (s) => _SurahTile(
                        surah: s,
                        onTap: () => context.go('/surah/${s.number}'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LastReadCard extends ConsumerWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final Surah surah;
  const _LastReadCard({
    required this.data,
    required this.onTap,
    required this.surah,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark_rounded,
                        color: AppColors.gold,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        s.lastRead,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.isArabic ? surah.name : surah.englishName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${s.ayah} ${s.toLocalNum(data['ayah'].toString())} • ${s.juz} ${s.toLocalNum(data['juz'].toString())}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.menu_book_rounded,
              color: AppColors.gold,
              size: 48,
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahTile extends ConsumerWidget {
  final Surah surah;
  final VoidCallback onTap;
  const _SurahTile({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  s.toLocalNum(surah.number.toString()),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.englishName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${surah.numberOfAyahs} ${s.verses} • ${surah.revelationType.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Arabic name + meaning
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  surah.name,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  surah.englishMeaning,
                  style: const TextStyle(fontSize: 11, color: AppColors.gold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
