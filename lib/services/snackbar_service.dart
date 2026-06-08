import 'package:flutter/material.dart';

/// Global SnackBar service that can be accessed from anywhere
class SnackBarService {
  static final SnackBarService _instance = SnackBarService._internal();

  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  SnackBarService._internal();

  factory SnackBarService() {
    return _instance;
  }

  /// Initialize the service with the scaffold messenger key
  void initialize(GlobalKey<ScaffoldMessengerState> key) {
    scaffoldMessengerKey = key;
  }

  /// Show a snackbar message
  void show({
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 4),
  }) {
    final state = scaffoldMessengerKey.currentState;
    if (state == null) return;

    state
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          duration: duration,
        ),
      );
  }

  /// Show a success message
  void showSuccess({
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(message: message, isError: false, duration: duration);
  }

  /// Show an error message
  void showError({
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(message: message, isError: true, duration: duration);
  }
}

/// Global SnackBar service instance
final snackBarService = SnackBarService();
