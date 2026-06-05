import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._values);

  final Locale locale;
  final Map<String, dynamic> _values;

  static final Map<String, Map<String, dynamic>> _cache = {};

  static Future<AppLocalizations> load(Locale locale) async {
    final code = supportedLanguageCodes.contains(locale.languageCode)
        ? locale.languageCode
        : 'en';

    final Map<String, dynamic> values = await _loadValues(code);
    return AppLocalizations(Locale(code), values);
  }

  static Future<void> preloadEnglish() => _loadValues('en');

  static Future<Map<String, dynamic>> _loadValues(String code) async {
    final cached = _cache[code];
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('assets/i18n/$code.json');
    final values = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    _cache[code] = values;
    return values;
  }

  factory AppLocalizations.fallback(Locale locale) {
    final code = supportedLanguageCodes.contains(locale.languageCode)
        ? locale.languageCode
        : 'en';
    final values = _cache[code] ?? _cache['en'] ?? const <String, dynamic>{};
    return AppLocalizations(Locale(code), values);
  }

  static const supportedLanguageCodes = ['en', 'ar'];

  bool get isArabic => locale.languageCode == 'ar';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  String text(String key) {
    final String? value = _values[key] as String?;
    if (value != null) return value;

    final String? englishValue = _cache['en']?[key] as String?;
    if (englishValue != null) return englishValue;

    return key;
  }

  Locale get alternateLocale =>
      isArabic ? const Locale('en') : const Locale('ar');
}

class AppLocalizationScope extends InheritedWidget {
  const AppLocalizationScope({
    super.key,
    required this.localizations,
    required this.changeLanguage,
    required super.child,
  });

  final AppLocalizations localizations;
  final Future<void> Function(Locale locale) changeLanguage;

  static AppLocalizationScope of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<AppLocalizationScope>();
    assert(result != null, 'No AppLocalizationScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppLocalizationScope oldWidget) {
    return oldWidget.localizations.locale != localizations.locale;
  }
}

extension AppLocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizationScope.of(this).localizations;

  Future<void> toggleLanguage() {
    final scope = AppLocalizationScope.of(this);
    return scope.changeLanguage(scope.localizations.alternateLocale);
  }
}
