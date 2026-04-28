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
            builder: (context, child) {
              final media = MediaQuery.of(context);
              final double width = media.size.width;
              final double widthScale = width <= 360
                  ? 0.92
                  : width <= 420
                  ? 1.0
                  : 1.06;
              final double baseScale = media.textScaler.scale(1.0);
              final clampedScale = TextScaler.linear(
                (baseScale * widthScale).clamp(0.88, 1.16),
              );

              return MediaQuery(
                data: media.copyWith(textScaler: clampedScale),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool shouldConstrain = constraints.maxWidth > 520;
                    if (!shouldConstrain) {
                      return child ?? const SizedBox.shrink();
                    }
                    return ColoredBox(
                      color: const Color(0xFFFFFAF5),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: child ?? const SizedBox.shrink(),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
