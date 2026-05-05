import 'dart:io';

import 'package:flutter/foundation.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (
        X509Certificate cert,
        String host,
        int port,
        ) {
      if (kReleaseMode) {
        return false;
      }
      return true;
    };
    return client;
  }
}