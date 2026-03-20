import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

class EducationApp extends StatelessWidget {
  const EducationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arab Universities',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF8A03C),
          primary: const Color(0xFFF29A38),
          secondary: const Color(0xFF95E1B0),
          surface: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
