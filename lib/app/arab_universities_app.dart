import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../controllers/language_controller.dart';
import '../core/app_localizations.dart';
import '../core/bloc/app_cubit.dart';
import '../core/app_theme.dart';
import '../screens/splash_screen.dart';
import '../services/snackbar_service.dart';
import '../widgets/network_connectivity_wrapper.dart';

class ArabUniversitiesApp extends StatefulWidget {
  const ArabUniversitiesApp({super.key});

  @override
  State<ArabUniversitiesApp> createState() => _ArabUniversitiesAppState();
}

class _ArabUniversitiesAppState extends State<ArabUniversitiesApp> {
  late final LanguageCubit _languageCubit;
  late final Future<void> _loadLanguageFuture;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _languageCubit = LanguageCubit();
    _loadLanguageFuture = Future.wait<void>([
      _languageCubit.loadSavedLocale(),
      AppLocalizations.preloadEnglish(),
      initializeDateFormatting('ar'),
      initializeDateFormatting('en'),
    ]);
    // Initialize SnackBar service with the global key
    snackBarService.initialize(_scaffoldMessengerKey);
  }

  @override
  void dispose() {
    _languageCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadLanguageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SizedBox.shrink(),
          );
        }

        return AppCubitBuilder<LanguageCubit, LanguageState>(
          cubit: _languageCubit,
          builder: (context, languageState) {
            final Locale locale = languageState.locale;

            return FutureBuilder<AppLocalizations>(
              future: AppLocalizations.load(locale),
              builder: (context, snapshot) {
                final localizations =
                    snapshot.data ?? AppLocalizations.fallback(locale);

                return AppLocalizationScope(
                  localizations: localizations,
                  changeLanguage: _languageCubit.changeLanguage,
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Arab Universities',
                    theme: AppTheme.theme,
                    locale: locale,
                    scaffoldMessengerKey: _scaffoldMessengerKey,
                    supportedLocales: AppLocalizations.supportedLanguageCodes
                        .map(Locale.new)
                        .toList(growable: false),
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                    ],
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

                      return Directionality(
                        textDirection: localizations.textDirection,
                        child: MediaQuery(
                          data: media.copyWith(textScaler: clampedScale),
                          child: NetworkConnectivityWrapper(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final bool shouldConstrain =
                                    constraints.maxWidth > 520;
                                if (!shouldConstrain) {
                                  return child ?? const SizedBox.shrink();
                                }
                                return ColoredBox(
                                  color: const Color(0xFFFFFAF5),
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 520),
                                      child: child ?? const SizedBox.shrink(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    home: const SplashScreen(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
