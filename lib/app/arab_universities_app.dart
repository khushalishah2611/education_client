import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../screens/splash_screen.dart';

class ArabUniversitiesApp extends StatefulWidget {
  const ArabUniversitiesApp({super.key});

  @override
  State<ArabUniversitiesApp> createState() => _ArabUniversitiesAppState();
}

class _ArabUniversitiesAppState extends State<ArabUniversitiesApp> {
  Locale _locale = const Locale('en');

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppLocalizations>(
      future: AppLocalizations.load(_locale),
      builder: (context, snapshot) {
        final localizations = snapshot.data ?? AppLocalizations.fallback(_locale);

        return AppLocalizationScope(
          localizations: localizations,
          changeLanguage: _changeLanguage,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Arab Universities',
            theme: AppTheme.theme,
            locale: _locale,
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
