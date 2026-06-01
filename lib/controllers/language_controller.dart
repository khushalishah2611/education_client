import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_localizations.dart';
import '../core/bloc/app_cubit.dart';

class LanguageState {
  const LanguageState({required this.locale});

  final Locale locale;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LanguageState && other.locale == locale;
  }

  @override
  int get hashCode => locale.hashCode;
}

class LanguageCubit extends AppCubit<LanguageState> {
  LanguageCubit() : super(const LanguageState(locale: Locale('en')));

  static const String _languagePreferenceKey = 'selected_language_code';

  Locale get locale => state.locale;

  Future<void> loadSavedLocale() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? savedLanguageCode = preferences.getString(
      _languagePreferenceKey,
    );

    emit(LanguageState(locale: _supportedLocaleFromCode(savedLanguageCode)));
  }

  Future<void> changeLanguage(Locale locale) async {
    final Locale supportedLocale = _supportedLocaleFromCode(
      locale.languageCode,
    );
    if (state.locale == supportedLocale) return;

    emit(LanguageState(locale: supportedLocale));

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _languagePreferenceKey,
      supportedLocale.languageCode,
    );
  }

  Future<void> toggleLanguage() {
    return changeLanguage(
      state.locale.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar'),
    );
  }

  Locale _supportedLocaleFromCode(String? languageCode) {
    if (languageCode != null &&
        AppLocalizations.supportedLanguageCodes.contains(languageCode)) {
      return Locale(languageCode);
    }
    return const Locale('en');
  }
}
