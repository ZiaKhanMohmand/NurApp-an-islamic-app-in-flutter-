import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String language; // 'en' or 'ar'
  final String calculationMethod;
  final String madhab;

  SettingsState({
    this.themeMode = ThemeMode.light,
    this.language = 'en',
    this.calculationMethod = 'Muslim World League',
    this.madhab = 'Hanafi',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    String? calculationMethod,
    String? madhab,
  }) => SettingsState(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    calculationMethod: calculationMethod ?? this.calculationMethod,
    madhab: madhab ?? this.madhab,
  );
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _load();
    return SettingsState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode') ?? false;
    final lang = prefs.getString('language') ?? 'en';
    final method =
        prefs.getString('calculation_method') ?? 'Muslim World League';
    final madhab = prefs.getString('madhab') ?? 'Hanafi';
    state = state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      language: lang,
      calculationMethod: method,
      madhab: madhab,
    );
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = state.themeMode == ThemeMode.dark;
    await prefs.setBool('dark_mode', !isDark);
    state = state.copyWith(
      themeMode: isDark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    state = state.copyWith(language: lang);
  }

  Future<void> setCalculationMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calculation_method', method);
    state = state.copyWith(calculationMethod: method);
  }

  Future<void> setMadhab(String madhab) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('madhab', madhab);
    state = state.copyWith(madhab: madhab);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
