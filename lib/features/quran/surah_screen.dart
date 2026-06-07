import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nur_app/core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import 'quran_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SurahScreen extends ConsumerStatefulWidget {
  final int number;
  const SurahScreen({super.key, required this.number});
  @override
  ConsumerState<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends ConsumerState<SurahScreen> {
  List<Ayah> _ayahs = [];
  bool _loading = true;
  double _fontSize = 22;
  final Set<int> _bookmarked = {};
  Surah? _surah;

  final TextEditingController _ayahController = TextEditingController();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void dispose() {
    _ayahController.dispose();
    super.dispose();
  }

  void _jumpToAyah(String val) {
    final num = int.tryParse(val);
    if (num == null || num < 1 || num > _ayahs.length) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enter 1 – ${_ayahs.length}')));
      return;
    }
    _ayahController.clear();
    FocusScope.of(context).unfocus();
    _itemScrollController.scrollTo(
      index: num - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = ref.read(stringsProvider);
    final results = await Future.wait([
      QuranService.fetchAyahs(widget.number),
      QuranService.fetchSurahs(),
    ]);
    final ayahs = results[0] as List<Ayah>;
    final surahs = results[1] as List<Surah>;
    final surah = surahs.firstWhere((su) => su.number == widget.number);

    // get saved ayah BEFORE overwriting lastRead
    final lastRead = await QuranService.getLastRead();
    final savedAyah = (lastRead != null && lastRead['surah'] == widget.number)
        ? (lastRead['ayah'] as int)
        : 1;

    await QuranService.saveLastRead(
      widget.number,
      s.isArabic ? surah.name : surah.englishName,
      savedAyah,
      1,
    );

    if (!mounted) return;
    setState(() {
      _ayahs = ayahs;
      _surah = surah;
      _loading = false;
    });

    // scroll to saved ayah after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (savedAyah > 1) {
        _itemScrollController.scrollTo(
          index: savedAyah - 1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
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
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: () => context.go('/quran'),
                  ),
                  Expanded(
                    child: Text(
                      _surah == null
                          ? s.toLocalNum(widget.number.toString())
                          : (s.isArabic ? _surah!.name : _surah!.englishName),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.text_decrease_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    onPressed: () => setState(
                      () => _fontSize = (_fontSize - 2).clamp(16, 36),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.text_increase_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    onPressed: () => setState(
                      () => _fontSize = (_fontSize + 2).clamp(16, 36),
                    ),
                  ),
                ],
              ),
            ),

            // Jump to ayah
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ayahController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: s.jumpToAyah,
                        hintStyle: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.tag_rounded,
                          color: AppColors.onSurfaceVariant,
                          size: 18,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _jumpToAyah,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _jumpToAyah(_ayahController.text),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              )
            else
              Expanded(
                child: ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _ayahs.length,
                  itemBuilder: (_, i) => _AyahCard(
                    ayah: _ayahs[i],
                    fontSize: _fontSize,
                    bookmarked: _bookmarked.contains(_ayahs[i].number),
                    onBookmark: () {
                      final ayahNum = _ayahs[i].number;
                      final s = ref.read(stringsProvider);
                      setState(() {
                        if (_bookmarked.contains(ayahNum)) {
                          _bookmarked.remove(ayahNum);
                        } else {
                          _bookmarked.add(ayahNum);
                          QuranService.saveLastRead(
                            widget.number,
                            s.isArabic ? _surah!.name : _surah!.englishName,
                            ayahNum,
                            1,
                          );
                        }
                      });
                    },
                    onCopy: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: '${_ayahs[i].arabic}\n${_ayahs[i].translation}',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verse copied!')),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AyahCard extends ConsumerWidget {
  final Ayah ayah;
  final double fontSize;
  final bool bookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onCopy;
  const _AyahCard({
    required this.ayah,
    required this.fontSize,
    required this.bookmarked,
    required this.onBookmark,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: bookmarked ? AppColors.gold : AppColors.surfaceVariant,
          width: bookmarked ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onBookmark,
                    child: Icon(
                      bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: bookmarked
                          ? AppColors.gold
                          : AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onCopy,
                    child: const Icon(
                      Icons.copy_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 18,
                    ),
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer,
                ),
                child: Center(
                  child: Text(
                    s.toLocalNum(ayah.number.toString()),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                ayah.arabic,
                style: TextStyle(
                  fontSize: fontSize,
                  height: 2.0,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const Divider(height: 20, color: AppColors.surfaceVariant),

          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ayah.translation,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
