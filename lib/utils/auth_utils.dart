import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/login_screen.dart';
import '../services/application_api_service.dart';

/// Checks if an exception is a "Student user not found" error (404)
bool isStudentNotFoundError(Exception? exception) {
  if (exception is ApplicationApiException) {
    return exception.statusCode == 404 &&
        exception.message.contains('Student user not found');
  }
  return false;
}

/// Performs logout: clears preferences and redirects to login screen
Future<void> performLogout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  if (!context.mounted) return;

  final navigator = Navigator.of(context);
  navigator.pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (_) => const LoginScreen(),
    ),
    (route) => false,
  );
}
