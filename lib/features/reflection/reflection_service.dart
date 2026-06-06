import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReflectionData {
  final String arabic;
  final String translation;
  final String reference;
  final String insight;
  final String theme;

  ReflectionData({
    required this.arabic,
    required this.translation,
    required this.reference,
    required this.insight,
    required this.theme,
  });

  Map<String, dynamic> toJson() => {
    'arabic': arabic,
    'translation': translation,
    'reference': reference,
    'insight': insight,
    'theme': theme,
  };

  factory ReflectionData.fromJson(Map<String, dynamic> j) => ReflectionData(
    arabic: j['arabic'],
    translation: j['translation'],
    reference: j['reference'],
    insight: j['insight'],
    theme: j['theme'],
  );
}

class ReflectionService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const _model = 'llama-3.3-70b-versatile';

  static Future<ReflectionData> fetchReflection({bool isArabic = false}) async {
    final cached = await _getCached(isArabic: isArabic);
    if (cached != null) return cached;

    final response = await http
        .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': _model,
            'max_tokens': 400,
            'messages': [
              {
                'role': 'system',
                'content':
                    '''You are an Islamic scholar. Return ONLY valid JSON, no markdown, no extra text.
Format exactly:
{
  "arabic": "Arabic Quran verse text",
  "translation": "${isArabic ? 'Arabic tafsir/explanation of the verse' : 'English translation'}",
  "reference": "${isArabic ? 'اسم السورة، الفصل:الآية' : 'Surah Name, Chapter:Verse'}",
  "insight": "${isArabic ? '2-3 جملة تأمل عملي بالعربية للمسلم المعاصر' : '2-3 sentence practical reflection for a modern Muslim'}",
  "theme": "${isArabic ? 'كلمة واحدة موضوع مثل الصبر' : 'One word theme e.g. Patience'}"
}''',
              },
              {
                'role': 'user',
                'content': isArabic
                    ? 'أعطني آية قرآنية عشوائية مع تأمل لهذا اليوم. أرجع JSON فقط.'
                    : 'Give me a random Quran verse with reflection for today. Return only JSON.',
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Groq API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final text = data['choices'][0]['message']['content'] as String;
    final clean = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final reflection = ReflectionData.fromJson(jsonDecode(clean));
    await _cache(reflection, isArabic: isArabic);
    return reflection;
  }

  static Future<void> _cache(ReflectionData r, {bool isArabic = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = isArabic ? 'ar' : 'en';
    await prefs.setString('reflection_date_$key', today);
    await prefs.setString('reflection_data_$key', jsonEncode(r.toJson()));
  }

  static Future<ReflectionData?> _getCached({bool isArabic = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = isArabic ? 'ar' : 'en';
    if (prefs.getString('reflection_date_$key') != today) return null;
    final raw = prefs.getString('reflection_data_$key');
    if (raw == null) return null;
    return ReflectionData.fromJson(jsonDecode(raw));
  }

  static Future<ReflectionData> refreshReflection({
    bool isArabic = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = isArabic ? 'ar' : 'en';
    await prefs.remove('reflection_date_$key');
    return fetchReflection(isArabic: isArabic);
  }

  // Save to favourites
  static Future<void> saveToFavourites(ReflectionData r) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_reflections') ?? [];
    saved.add(jsonEncode(r.toJson()));
    await prefs.setStringList('saved_reflections', saved);
  }
}
