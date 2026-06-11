import 'dart:convert';
import 'package:flutter/services.dart';

class QuranTimingService {
  // Map key: "surah_ayah" → list of [wordStart, wordEnd, startMs, endMs]
  static Map<String, List<List<int>>> _timings = {};
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(
      'assets/timings/Alafasy_128kbps.json',
    );
    final List data = jsonDecode(raw);
    for (final entry in data) {
      final key = '${entry['surah']}_${entry['ayah']}';
      final segs = (entry['segments'] as List)
          .map((s) => (s as List).map((v) => v as int).toList())
          .toList();
      _timings[key] = segs;
    }
    _loaded = true;
  }

  // Returns list of [startMs, endMs] per word index
  static List<(int, int)>? getWordTimings(int surah, int ayah, int wordCount) {
    final key = '${surah}_${ayah}';
    final segs = _timings[key];
    if (segs == null) return null;

    // Build per-word timing from segments
    final result = List<(int, int)>.filled(wordCount, (0, 0));
    for (final seg in segs) {
      final wStart = seg[0], wEnd = seg[1], tStart = seg[2], tEnd = seg[3];
      final wordSpan = wEnd - wStart;
      if (wordSpan <= 0) continue;
      final msPerWord = (tEnd - tStart) ~/ wordSpan;
      for (int w = wStart; w < wEnd && w < wordCount; w++) {
        final offset = w - wStart;
        result[w] = (
          tStart + offset * msPerWord,
          tStart + (offset + 1) * msPerWord,
        );
      }
    }
    return result;
  }
}
