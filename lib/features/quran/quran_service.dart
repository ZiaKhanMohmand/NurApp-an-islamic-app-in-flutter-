import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Surah {
  final int number;
  final String name, englishName, englishMeaning, revelationType;
  final int numberOfAyahs;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishMeaning,
    required this.revelationType,
    required this.numberOfAyahs,
  });

  factory Surah.fromJson(Map<String, dynamic> j) => Surah(
    number: j['number'],
    name: j['name'],
    englishName: j['englishName'],
    englishMeaning: j['englishNameTranslation'],
    revelationType: j['revelationType'],
    numberOfAyahs: j['numberOfAyahs'],
  );
}

class Ayah {
  final int number;
  final String arabic, translation;
  Ayah({required this.number, required this.arabic, required this.translation});
}

class QuranService {
  static Future<List<Surah>> fetchSurahs() async {
    final url = Uri.parse('https://api.alquran.cloud/v1/surah');
    final res = await http.get(url).timeout(const Duration(seconds: 10));
    final data = jsonDecode(res.body);
    final list = data['data'] as List;
    return list.map((e) => Surah.fromJson(e)).toList();
  }

  static Future<List<Ayah>> fetchAyahs(int surahNumber) async {
    // Fetch Arabic + English in parallel
    final results = await Future.wait([
      http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber')),
      http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber/en.asad'),
      ),
    ]);

    final arabic = jsonDecode(results[0].body)['data']['ayahs'] as List;
    final english = jsonDecode(results[1].body)['data']['ayahs'] as List;

    return List.generate(
      arabic.length,
      (i) => Ayah(
        number: arabic[i]['numberInSurah'],
        arabic: arabic[i]['text'],
        translation: english[i]['text'],
      ),
    );
  }

  // Save last read
  static Future<void> saveLastRead(
    int surah,
    String surahName,
    int ayah,
    int juz,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_surah', surah);
    await prefs.setString('last_surah_name', surahName);
    await prefs.setInt('last_ayah', ayah);
    await prefs.setInt('last_juz', juz);
  }

  static Future<Map<String, dynamic>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getInt('last_surah');
    if (surah == null) return null;
    return {
      'surah': surah,
      'surahName': prefs.getString('last_surah_name') ?? '',
      'ayah': prefs.getInt('last_ayah') ?? 1,
      'juz': prefs.getInt('last_juz') ?? 1,
    };
  }
}
