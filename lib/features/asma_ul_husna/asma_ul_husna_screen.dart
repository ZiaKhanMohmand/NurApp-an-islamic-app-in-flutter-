import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  static const _gold = Color(0xFFC9A84C);

  @override
  void initState() {
    super.initState();
    _loadNames();
    _searchController.addListener(_onSearch);
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

  @override
  void dispose() {
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _gold),
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
              style: TextStyle(
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

      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : CustomScrollView(
              slivers: [
                // App Bar

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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
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
      onTap: () => _showDetail(context, s),
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
            // Number badge
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

            // Arabic name
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

            // Transliteration
            Text(
              name['transliteration'],
              style: TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 2),

            // Meaning
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

  void _showDetail(BuildContext context, AppStrings s) {
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
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Number
            Text(
              '${s.toLocalNum('${name['number']}')} ${s.ofNinetyNine}',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),

            // Arabic large
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

            // Divider
            Container(height: 1, color: _gold.withValues(alpha: 0.15)),
            const SizedBox(height: 16),

            // Transliteration
            Text(
              name['transliteration'],
              style: TextStyle(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Meaning
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
