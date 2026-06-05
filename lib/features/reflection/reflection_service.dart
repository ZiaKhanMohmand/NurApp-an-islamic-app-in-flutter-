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

  static Future<ReflectionData> fetchReflection() async {
    // Check cache — same reflection all day
    final cached = await _getCached();
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
  "translation": "English translation",
  "reference": "Surah Name, Chapter:Verse",
  "insight": "2-3 sentence practical reflection for a modern Muslim",
  "theme": "One word theme e.g. Patience"
}''',
              },
              {
                'role': 'user',
                'content':
                    'Give me a random Quran verse with reflection for today. Return only JSON.',
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

    // Clean any accidental markdown
    final clean = text.replaceAll('```json', '').replaceAll('```', '').trim();

    final reflection = ReflectionData.fromJson(jsonDecode(clean));
    await _cache(reflection);
    return reflection;
  }

  // Cache reflection for today
  static Future<void> _cache(ReflectionData r) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString('reflection_date', today);
    await prefs.setString('reflection_data', jsonEncode(r.toJson()));
  }

  static Future<ReflectionData?> _getCached() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final cachedDate = prefs.getString('reflection_date');
    if (cachedDate != today) return null;
    final raw = prefs.getString('reflection_data');
    if (raw == null) return null;
    return ReflectionData.fromJson(jsonDecode(raw));
  }

  // Force fresh (ignore cache)
  static Future<ReflectionData> refreshReflection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reflection_date');
    return fetchReflection();
  }

  // Save to favourites
  static Future<void> saveToFavourites(ReflectionData r) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_reflections') ?? [];
    saved.add(jsonEncode(r.toJson()));
    await prefs.setStringList('saved_reflections', saved);
  }
}
